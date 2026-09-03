import json
import logging
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)


class DestinoNaoVazioError(Exception):
    """Destino PostGIS já tem feições e a política de reexecução é 'abortar'.

    A gravação é sempre em APPEND, então rodar a mesma conversão duas vezes
    duplicaria as feições sem levantar erro nenhum. Esta exceção existe para
    que essa duplicação exija uma decisão explícita em vez de acontecer em
    silêncio.
    """

    def __init__(self, schema: str, contagens: dict):
        self.schema = schema
        self.contagens = contagens
        super().__init__(self._mensagem())

    def _mensagem(self) -> str:
        linhas = [
            f"Destino não está vazio: {len(self.contagens)} tabela(s) do schema "
            f"'{self.schema}' já têm feições, e a gravação é em APPEND "
            "(rodar de novo DUPLICA as feições, sem erro).",
            "",
        ]
        for tabela, n in sorted(self.contagens.items(), key=lambda kv: -kv[1])[:10]:
            linhas.append(f"  {self.schema}.{tabela}: {n} feição(ões)")
        if len(self.contagens) > 10:
            linhas.append(f"  ... e mais {len(self.contagens) - 10} tabela(s)")
        linhas += [
            "",
            "Nada foi escrito. Decida explicitamente com --se-existir:",
            "  --se-existir abortar   (padrão) não escreve nada",
            "  --se-existir replace   esvazia essas tabelas (DELETE, preserva a "
            "estrutura EDGV) e grava",
            "  --se-existir append    acrescenta mesmo assim, aceitando a duplicação",
        ]
        return "\n".join(linhas)


class TabelaDestinoAusenteError(Exception):
    """A conversão produziu classe que não existe no schema de destino.

    Sem esta checagem o `to_postgis(if_exists="append")` CRIA a tabela, e ela
    nasce crua: sem chave primária, sem domínio, sem CHECK e sem gatilho, com
    as colunas do modelo de ORIGEM. O banco continua de pé e deixa de ser
    EDGV, em silêncio. Medido em 2026-08-13: uma carga Overture plantou
    `edgv.llp_limite_legal_a` num banco Topo 1.4, que tem 95 classes e passou
    a ter 96.

    A causa quase sempre é mapeamento sem discriminador: duas ou mais classes
    de origem apontam para a mesma classe de destino e nenhuma traz filtro, ou
    o afixo de geometria gera um nome que o modelo de destino não tem.
    """

    def __init__(self, schema: str, ausentes: dict):
        self.schema = schema
        self.ausentes = ausentes
        super().__init__(self._mensagem())

    def _mensagem(self) -> str:
        linhas = [
            f"A conversão produziu {len(self.ausentes)} classe(s) que NÃO existem "
            f"no schema '{self.schema}' do destino. Nada foi escrito.",
            "",
        ]
        for tabela, n in sorted(self.ausentes.items(), key=lambda kv: -kv[1]):
            linhas.append(f"  {self.schema}.{tabela}: {n} feição(ões) sem onde entrar")
        linhas += [
            "",
            "O destino NÃO é o modelo que o mapeamento supõe, ou o mapeamento manda",
            "duas classes de origem para a mesma classe de destino sem discriminador.",
            "Confira, no mapeamento, se essas classes têm filtro de classe, e se o",
            "afixo de geometria gera um nome que o modelo de destino tem de fato.",
        ]
        return "\n".join(linhas)


class ValorForaDeDominioError(Exception):
    """A origem guarda valor que o dominio ou o CHECK do destino recusa.

    Sem esta guarda a descoberta vem tarde demais. A gravacao tenta o lote, o
    banco recusa, o escritor cai no retry linha a linha, e cada linha recusada
    vira um WARNING no log. A conversao termina "com sucesso" e uma classe pode
    ter saido VAZIA. Medido em 2026-09-03 numa conversao Topo 1.3 para 1.4:
    `llp_limite_legal_l` gravou 0 de 10 feicoes porque o dado trazia `tipo = 3`,
    codigo que nenhum dos dois modelos declara, e o resumo nao disse nada.

    A checagem e so leitura, roda antes de ler feicao, e custa um SELECT
    DISTINCT por coluna com dominio.
    """

    def __init__(self, graves: list, textos: list):
        self.graves = graves
        self.textos = textos
        super().__init__(self._mensagem())

    def _mensagem(self) -> str:
        linhas = [
            f"{len(self.graves) + len(self.textos)} coluna(s) da origem levam "
            "valor que o destino RECUSA. Nada foi lido nem escrito.",
            "",
        ]
        for a in self.graves:
            n = a.get("feicoes")
            linhas.append(
                f"  {a['tabela_origem']}.{a['coluna_origem']} -> "
                f"{a['tabela_destino']}.{a['coluna_destino']}: "
                f"{a['codigos_sem_destino']} em "
                f"{n if n is not None else '?'} feição(ões) ({a['barreira']})"
            )
        for t, c, v in self.textos:
            linhas.append(
                f"  {t}.{c}: guarda TEXTO {v}, e o destino quer código numérico"
            )
        linhas += [
            "",
            "Três saídas, e a escolha é sua:",
            "  1. declarar a tradução no arquivo de mapeamento, se o valor tem",
            "     equivalente no modelo de destino;",
            "  2. declarar um filtro no mapeamento, se o conceito não existe lá",
            "     e a feição deve mesmo ficar de fora;",
            "  3. --ignorar-dominio, aceitando perder essas feições uma a uma.",
            "",
            "Para ver a lista sem converter: --dry-run.",
        ]
        return "\n".join(linhas)


@dataclass
class ConversionError:
    source_table: str
    feature_index: int
    error_type: str  # CLASS_NOT_FOUND, INVALID_GEOM, READ_ERROR, WRITE_ERROR
    message: str


@dataclass
class ConversionReport:
    total_features: int = 0
    converted_features: int = 0
    written_features: int = 0
    skipped_class_not_found: int = 0
    skipped_invalid_geom: int = 0
    errors: list = field(default_factory=list)
    # {tabela de origem: n} das feicoes que o mapeamento descartou de proposito,
    # por um filtro declarado, contra as que ele simplesmente nao conhece
    descartadas_por_filtro: dict = field(default_factory=dict)
    classes_sem_mapeamento: dict = field(default_factory=dict)
    # {tabela de destino: (esperado, gravado)} quando o destino recusou linha.
    # Sem isso, uma classe que sai com ZERO feicao some no meio do log.
    escrita_incompleta: dict = field(default_factory=dict)

    def registrar_descarte(self, tabela: str, por_filtro: bool):
        alvo = self.descartadas_por_filtro if por_filtro else self.classes_sem_mapeamento
        alvo[tabela] = alvo.get(tabela, 0) + 1

    def registrar_escrita(self, tabela: str, esperado: int, gravado: int):
        if gravado < esperado:
            self.escrita_incompleta[tabela] = (esperado, gravado)
            logger.error(
                "%s: o destino RECUSOU %d de %d feicao(oes)%s",
                tabela, esperado - gravado, esperado,
                ". A CLASSE SAIU VAZIA." if gravado == 0 else "",
            )

    def houve_perda(self) -> bool:
        """Serve de codigo de saida: perda de feicao nao e aviso, e falha."""
        return bool(self.errors or self.escrita_incompleta
                    or self.classes_sem_mapeamento)

    def add_error(self, error: ConversionError):
        self.errors.append(error)
        logger.warning(
            "[%s] table=%s idx=%d: %s",
            error.error_type, error.source_table, error.feature_index, error.message,
        )

    def summary(self) -> str:
        lines = [
            "=== Relatório de Conversão ===",
            f"Total de feições processadas: {self.total_features}",
            f"Feições convertidas: {self.converted_features}",
            f"Feições GRAVADAS no destino: {self.written_features}",
            f"Ignoradas (classe não encontrada): {self.skipped_class_not_found}",
            f"Ignoradas (geometria inválida): {self.skipped_invalid_geom}",
            f"Erros: {len(self.errors)}",
        ]
        if self.descartadas_por_filtro:
            lines.append("")
            lines.append("Descartadas por FILTRO declarado no mapeamento (esperado):")
            for t, n in sorted(self.descartadas_por_filtro.items(), key=lambda kv: -kv[1]):
                lines.append(f"  {t}: {n} feição(ões)")
        if self.classes_sem_mapeamento:
            lines.append("")
            lines.append("Classes de origem SEM entrada no mapeamento (perda NÃO declarada):")
            for t, n in sorted(self.classes_sem_mapeamento.items(), key=lambda kv: -kv[1]):
                lines.append(f"  {t}: {n} feição(ões)")
        if self.escrita_incompleta:
            lines.append("")
            lines.append("ESCRITA INCOMPLETA, o destino recusou feição:")
            for t, (esp, grav) in sorted(self.escrita_incompleta.items()):
                marca = "   <-- CLASSE VAZIA" if grav == 0 else ""
                lines.append(f"  {t}: {grav} de {esp} gravadas{marca}")
        if self.errors:
            lines.append("")
            lines.append("Detalhes dos erros:")
            for e in self.errors[:50]:
                lines.append(f"  [{e.error_type}] {e.source_table}[{e.feature_index}]: {e.message}")
            if len(self.errors) > 50:
                lines.append(f"  ... e mais {len(self.errors) - 50} erros")
        return "\n".join(lines)

    def to_dict(self) -> dict:
        return {
            "total_features": self.total_features,
            "converted_features": self.converted_features,
            "written_features": self.written_features,
            "skipped_class_not_found": self.skipped_class_not_found,
            "skipped_invalid_geom": self.skipped_invalid_geom,
            "descartadas_por_filtro": self.descartadas_por_filtro,
            "classes_sem_mapeamento": self.classes_sem_mapeamento,
            "escrita_incompleta": {
                t: {"esperado": e, "gravado": g}
                for t, (e, g) in self.escrita_incompleta.items()
            },
            "errors": [
                {
                    "source_table": e.source_table,
                    "feature_index": e.feature_index,
                    "error_type": e.error_type,
                    "message": e.message,
                }
                for e in self.errors
            ],
        }

    def export_json(self, path: str):
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, ensure_ascii=False, indent=2)
