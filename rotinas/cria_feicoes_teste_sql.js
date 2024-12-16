// Executar com: node --max-old-space-size=8192 index.js
const { Pool } = require('pg');
const fs = require('fs').promises;

class PostGISFeatureGenerator {
    constructor(dbParams) {
        console.log('Inicializando PostGIS Feature Generator...');
        this.dbParams = dbParams;
        this.masterfile = null;
        this.pool = new Pool(dbParams);

        this.pool.on('error', (err) => {
            console.error('Erro inesperado no pool de conexões:', err);
        });
    }

    async loadMasterfile(path) {
        try {
            console.log(`Carregando masterfile de: ${path}`);
            const data = await fs.readFile(path, 'utf-8');
            this.masterfile = JSON.parse(data);
            console.log('Masterfile carregado com sucesso');
        } catch (error) {
            console.error('Erro ao carregar masterfile:', error);
            throw error;
        }
    }

    getDomainValues(domainName) {
        const domain = this.masterfile.dominios.find(d => d.nome === domainName);
        const values = domain ? domain.valores.map(v => v.code) : [];
        return values;
    }

    getAllowedDomainValues(attr, domainValues, primitiveType) {
        if (!attr.valores) {
            return domainValues;
        }

        const valores = attr.valores;
        let result = [];

        if (Array.isArray(valores) && valores.every(x => typeof x === 'number')) {
            result = domainValues.filter(v => valores.includes(v));
        } else if (Array.isArray(valores) && valores.every(x => typeof x === 'object')) {
            const allowedCodes = valores.filter(valor =>
                !valor.primitivas || valor.primitivas.includes(primitiveType)
            ).map(valor => valor.code);
            result = domainValues.filter(v => allowedCodes.includes(v));
        } else if (typeof valores === 'object' && primitiveType in valores) {
            result = domainValues.filter(v => valores[primitiveType].includes(v));
        } else {
            result = domainValues;
        }

        return result;
    }

    createTestGeometry(primitiveType) {
        let wkt;
        switch (primitiveType) {
            case 'MultiPoint':
                wkt = 'MULTIPOINT((0 0))';
                break;
            case 'MultiLinestring':
                wkt = 'MULTILINESTRING((0 0, 1 1, 2 0))';
                break;
            case 'MultiPolygon':
                wkt = 'MULTIPOLYGON(((0 0, 2 0, 2 2, 0 2, 0 0)))';
                break;
            default:
                console.warn(`Tipo de primitiva não reconhecido: ${primitiveType}`);
                return null;
        }
        return wkt;
    }

    generateAttributeCombinations(classDef, primitiveType) {

        const blacklist = new Set([
            'visivel', 'exibir_lado_simbologia', 'sobreposto_transportes',
            'justificativa_txt', 'exibir_ponta_simbologia', 'dentro_de_massa_dagua',
            'dentro_massa_dagua', 'tipo_elemento_viario', 'material_construcao_elemento_viario',
            'posicao_pista_elemento_viario', 'posicao_rotulo', 'direcao_fixada',
            'em_galeria_bueiro', 'exibir_linha_rotulo', 'suprimir_bandeira'
        ]);

        const attrValues = {};
        const singleValueAttrs = {};

        for (const attr of classDef.atributos) {
            if (attr.primitivas && !attr.primitivas.includes(primitiveType)) {
                continue;
            }

            const attrName = attr.nome;

            if (blacklist.has(attrName)) {
                if (attr.mapa_valor) {
                    const domainValues = this.getDomainValues(attr.mapa_valor);
                    const allowedValues = this.getAllowedDomainValues(attr, domainValues, primitiveType);
                    if (allowedValues.length) {
                        singleValueAttrs[attrName] = allowedValues[0];
                    }
                } else {
                    switch (attr.tipo) {
                        case 'varchar(255)':
                            // Regras específicas para campos varchar
                            if (attrName === 'nr_pistas' || attrName === 'nr_faixas' || attrName === 'altitude_ortometrica' || attrName === 'altitude_geometrica') {
                                singleValueAttrs[attrName] = '1';
                            } else if (attrName === 'sigla') {
                                singleValueAttrs[attrName] = 'BR';
                            } else {
                                singleValueAttrs[attrName] = 'Teste';
                            }
                            break;
                        case 'integer':
                        case 'real':
                            singleValueAttrs[attrName] = 42;
                            break;
                        case 'boolean':
                            singleValueAttrs[attrName] = true;
                            break;
                    }
                }
                continue;
            }

            if (attr.mapa_valor) {
                const domainValues = this.getDomainValues(attr.mapa_valor);
                const allowedValues = this.getAllowedDomainValues(attr, domainValues, primitiveType);
                if (allowedValues.length) {
                    attrValues[attrName] = allowedValues;
                }
            } else {
                switch (attr.tipo) {
                    case 'varchar(255)':
                        // Regras específicas para campos varchar
                        if (attrName === 'nr_pistas' || attrName === 'nr_faixas' || attrName === 'altitude_ortometrica' || attrName === 'altitude_geometrica') {
                            attrValues[attrName] = ['1'];
                        } else if (attrName === 'sigla') {
                            attrValues[attrName] = ['BR'];
                        } else {
                            attrValues[attrName] = ['Teste'];
                        }
                        break;
                    case 'integer':
                    case 'real':
                        attrValues[attrName] = [42];
                        break;
                    case 'boolean':
                        attrValues[attrName] = [true];
                        break;
                }
            }
        }

        // Se não há valores variáveis, retorna apenas os valores únicos
        if (Object.keys(attrValues).length === 0) {
            if (Object.keys(singleValueAttrs).length > 0) {
                return [singleValueAttrs];
            }
            return [];
        }

        const keys = Object.keys(attrValues);
        const values = Object.values(attrValues);
        keys.forEach((key, index) => {
            console.log(`${key}: ${values[index].length} valores`);
        });

        const totalCombinations = values.reduce((acc, arr) => acc * arr.length, 1);
        if (totalCombinations > 10000) {
            console.warn(`Aviso: Gerando ${totalCombinations} combinações`);
        }

        // Gera todas combinações de uma vez usando loops aninhados
        const combinations = [];
        const indexes = new Array(values.length).fill(0);
        let i = 0;

        while (i < values.length) {
            // Cria uma combinação com os índices atuais
            const combination = {};
            for (let j = 0; j < values.length; j++) {
                combination[keys[j]] = values[j][indexes[j]];
            }

            // Adiciona regras específicas para infra_elemento_viario_l
            if (classDef.nome === 'elemento_viario' && classDef.categoria === 'infra') {
                // Regra 1: modal_uso 97 só pode ser usado se tipo = 501
                if (combination.tipo !== 501 && combination.modal_uso === 97) {
                    i = 0;
                    while (i < values.length) {
                        indexes[i]++;
                        if (indexes[i] < values[i].length) {
                            break;
                        }
                        indexes[i] = 0;
                        i++;
                    }
                    continue;
                }
                
                // Regra 2: material_construcao 97 só pode ser usado se tipo = 401 ou 402
                if (combination.material_construcao === 97 && 
                    combination.tipo !== 401 && combination.tipo !== 402) {
                    i = 0;
                    while (i < values.length) {
                        indexes[i]++;
                        if (indexes[i] < values[i].length) {
                            break;
                        }
                        indexes[i] = 0;
                        i++;
                    }
                    continue;
                }
            }

            // Regras específicas para llp_ponto_controle
            if (classDef.nome === 'ponto_controle' && classDef.categoria === 'llp') {
                // situacao_marco 97 só pode ser usado se tipo = 9, 14, 15 ou 16
                const tiposPermitidos = [9, 14, 15, 16];
                if (combination.situacao_marco === 97 && !tiposPermitidos.includes(combination.tipo)) {
                    i = 0;
                    while (i < values.length) {
                        indexes[i]++;
                        if (indexes[i] < values[i].length) {
                            break;
                        }
                        indexes[i] = 0;
                        i++;
                    }
                    continue;
                }
            }

            combinations.push({ ...combination, ...singleValueAttrs });

            // Atualiza os índices
            i = 0;
            while (i < values.length) {
                indexes[i]++;
                if (indexes[i] < values[i].length) {
                    break;
                }
                indexes[i] = 0;
                i++;
            }
        }

        return combinations;
    }

    generateInsertSQL(schema, table, attributes, geomField, wkt) {
        const fields = [...Object.keys(attributes), geomField];
        const placeholders = fields.map((_, i) => `$${i + 1}`);

        const sql = `
            INSERT INTO ${schema}.${table} (${fields.join(', ')})
            VALUES (${placeholders.join(', ')})
        `;

        const values = [...Object.values(attributes), wkt];
        return { sql, values };
    }

    async generateTestFeatures(schema, table, className, category, primitiveType) {
        console.log(`\nGerando features de teste para ${schema}.${table}`);

        try {
            const classDef = findClassInMasterfile(this.masterfile, className, category);

            if (!classDef) {
                console.error(`Classe ${className} com categoria ${category} não encontrada`);
                return;
            }

            if (!classDef.primitivas.includes(primitiveType)) {
                console.error(`Primitiva ${primitiveType} não é válida para classe ${className}`);
                return;
            }

            const wkt = this.createTestGeometry(primitiveType);
            if (!wkt) return;

            const client = await this.pool.connect();

            try {
                await client.query('BEGIN');

                let count = 0;
                const batchSize = 1000;
                let batch = [];

                for (const attrs of this.generateAttributeCombinations(classDef, primitiveType)) {
                    const { sql, values } = this.generateInsertSQL(
                        schema, table, attrs, 'geom', wkt
                    );

                    batch.push({ sql, values });
                    count++;

                    if (batch.length >= batchSize) {
                        for (const item of batch) {
                            await client.query(item.sql, item.values);
                        }
                        batch = [];
                    }
                }

                if (batch.length > 0) {
                    for (const item of batch) {
                        await client.query(item.sql, item.values);
                    }
                }

                if (count === 0) {
                    const sql = `
                        INSERT INTO ${schema}.${table} (geom)
                        VALUES (ST_GeomFromText($1, 4674))
                    `;
                    await client.query(sql, [wkt]);
                }

                await client.query('COMMIT');
                console.log(`Features geradas com sucesso para ${schema}.${table}. Total: ${count}`);
            } catch (error) {
                console.error('Erro durante inserção, realizando rollback:', error);
                await client.query('ROLLBACK');
                throw error;
            } finally {
                client.release();
            }
        } catch (error) {
            console.error(`Erro ao gerar features para ${schema}.${table}:`, error);
            throw error;
        }
    }
}

function findClassInMasterfile(masterfile, className, category) {
    const findInClasses = classes =>
        classes.find(c => c.nome === className && c.categoria === category);

    const result = findInClasses(masterfile.classes) ||
        (masterfile.extension_classes && findInClasses(masterfile.extension_classes));

    return result;
}

function extractClassInfoFromTableName(tableName) {
    const parts = tableName.split('_');

    const primitiveSuffix = parts[parts.length - 1];
    const primitiveType = {
        'p': 'MultiPoint',
        'l': 'MultiLinestring',
        'a': 'MultiPolygon'
    }[primitiveSuffix];

    const category = parts[0];
    const className = parts.slice(1, -1).join('_');

    return [className, category, primitiveType];
}

async function main() {
    console.log('\n=== Iniciando processo de geração de features ===\n');

    const dbParams = {
        database: 'topo14',
        user: 'postgres',
        password: 'postgres',
        host: 'localhost',
        port: 5433
    };

    try {
        console.log('Configurando conexão com banco de dados:', {
            ...dbParams,
            password: '*****'
        });

        const generator = new PostGISFeatureGenerator(dbParams);
        console.log('Carregando masterfile...');
        await generator.loadMasterfile('c:/Diniz/modelagens/edgv_300_topo/1_4/master_file_300_topo_14.json');

        const client = await generator.pool.connect();
        console.log('Conectado ao banco de dados');

        try {
            console.log('Buscando tabelas no banco...');
            const result = await client.query(`
                SELECT schemaname, tablename 
                FROM pg_catalog.pg_tables 
                WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'public', 'dominios')
            `);
            console.log(`Total de tabelas encontradas: ${result.rows.length}`);

            for (const row of result.rows) {
                console.log(`\nProcessando tabela: ${row.schemaname}.${row.tablename}`);
                const [className, category, primitiveType] =
                    extractClassInfoFromTableName(row.tablename);

                if (!primitiveType) {
                    console.log('Tabela ignorada - tipo de primitiva não reconhecido');
                    continue;
                }

                try {
                    await generator.generateTestFeatures(
                        row.schemaname, row.tablename, className, category, primitiveType
                    );
                } catch (error) {
                    console.error(`Erro ao processar tabela ${row.tablename}:`, error);
                }
            }
        } finally {
            client.release();
        }

        await generator.pool.end();
        console.log('Pool de conexões encerrado');
    } catch (error) {
        console.error('Erro fatal durante execução:', error);
        process.exit(1);
    }
}

// Inicia o programa
main().catch(error => {
    console.error('Erro não tratado:', error);
    process.exit(1);
});