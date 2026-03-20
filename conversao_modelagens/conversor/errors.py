import json
import logging
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)


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
    skipped_class_not_found: int = 0
    skipped_invalid_geom: int = 0
    errors: list = field(default_factory=list)

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
            f"Ignoradas (classe não encontrada): {self.skipped_class_not_found}",
            f"Ignoradas (geometria inválida): {self.skipped_invalid_geom}",
            f"Erros: {len(self.errors)}",
        ]
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
            "skipped_class_not_found": self.skipped_class_not_found,
            "skipped_invalid_geom": self.skipped_invalid_geom,
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
