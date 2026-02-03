DO $$
DECLARE
    r RECORD;
    col_exists BOOLEAN;
BEGIN
    -- 1. Loop por todas as tabelas REAIS (exclui views) do schema 'edgv'
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'edgv'
    LOOP
        
        -- A) Adiciona osm_id (BigInt é recomendado para IDs do OSM)
        EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.tablename) || ' ADD COLUMN IF NOT EXISTS osm_id BIGINT;';
        
        -- B) Adiciona osm_type (Text para armazenar 'node', 'way', 'relation')
        EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.tablename) || ' ADD COLUMN IF NOT EXISTS osm_type TEXT;';

        -- C) Altera 'observacao' para TEXT (apenas se a coluna existir na tabela)
        SELECT EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_schema = 'edgv' 
              AND table_name = r.tablename 
              AND column_name = 'observacao'
        ) INTO col_exists;

        IF col_exists THEN
            -- O comando USING garante a conversão correta caso haja dados
            EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.tablename) || ' ALTER COLUMN observacao TYPE TEXT USING observacao::text;';
        END IF;

    END LOOP;
    
    RAISE NOTICE 'Atualização do schema EDGV concluída com sucesso.';
END $$;