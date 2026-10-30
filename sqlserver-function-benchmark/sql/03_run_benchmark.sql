/*
    03_run_benchmark.sql

    Percorre os cenários ativos e audita cada execução.
    No SSMS, habilite Include Actual Execution Plan (Ctrl+M)
    antes de executar para inspecionar o plano real de cada SELECT.
*/
SET NOCOUNT ON;
SET XACT_ABORT OFF;

DECLARE
    @ExecucaoID UNIQUEIDENTIFIER = NEWID(),
    @CenarioID INT,
    @Descricao VARCHAR(150),
    @Parametro INT,
    @AuditoriaID BIGINT,
    @DataInicio DATETIME2(3),
    @DataFim DATETIME2(3),
    @Quantidade BIGINT;

DECLARE cur_Benchmark CURSOR LOCAL FAST_FORWARD FOR
    SELECT CenarioID, Descricao, Parametro
    FROM dbo.Benchmark_Cenarios
    WHERE Ativo = 1
    ORDER BY CenarioID;

-- As mensagens aparecem na aba Messages do SSMS.
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

OPEN cur_Benchmark;

FETCH NEXT FROM cur_Benchmark
INTO @CenarioID, @Descricao, @Parametro;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @DataInicio = SYSDATETIME();
    SET @DataFim = NULL;
    SET @Quantidade = 0;
    SET @AuditoriaID = NULL;

    INSERT INTO dbo.Benchmark_Auditoria
    (
        ExecucaoID, CenarioID, Parametro, DataInicio, Status
    )
    VALUES
    (
        @ExecucaoID, @CenarioID, @Parametro, @DataInicio, 'EXECUTANDO'
    );

    SET @AuditoriaID = SCOPE_IDENTITY();

    BEGIN TRY
        PRINT '========================================';
        PRINT 'Execucao: ' + CONVERT(VARCHAR(36), @ExecucaoID);
        PRINT 'Cenario: ' + @Descricao;
        PRINT 'Parametro: ' + CONVERT(VARCHAR(20), @Parametro);

        /*
          O SELECT retorna as linhas ao cliente e permite inspecionar
          o plano real. Não substitua por COUNT(*) se a intenção for
          medir a consulta que consome todas as colunas.
        */
        SELECT
            PedidoID,
            ClienteID,
            DataPedido,
            Valor,
            Status
        FROM dbo.fn_ConsultarPedidos(@Parametro);

        -- Captura imediatamente a quantidade de linhas do SELECT anterior.
        SET @Quantidade = @@ROWCOUNT;
        SET @DataFim = SYSDATETIME();

        UPDATE dbo.Benchmark_Auditoria
        SET
            DataFim = @DataFim,
            DuracaoMs = DATEDIFF_BIG(MILLISECOND, @DataInicio, @DataFim),
            RegistrosRetornados = @Quantidade,
            Status = 'SUCESSO'
        WHERE AuditoriaID = @AuditoriaID;
    END TRY
    BEGIN CATCH
        SET @DataFim = SYSDATETIME();

        UPDATE dbo.Benchmark_Auditoria
        SET
            DataFim = @DataFim,
            DuracaoMs = DATEDIFF_BIG(MILLISECOND, @DataInicio, @DataFim),
            Status = 'ERRO',
            ErroNumero = ERROR_NUMBER(),
            ErroMensagem = ERROR_MESSAGE()
        WHERE AuditoriaID = @AuditoriaID;

        PRINT 'Falha no cenario ' + CONVERT(VARCHAR(20), @CenarioID)
            + ': ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM cur_Benchmark
    INTO @CenarioID, @Descricao, @Parametro;
END;

CLOSE cur_Benchmark;
DEALLOCATE cur_Benchmark;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

PRINT 'Benchmark finalizado. ExecucaoID: '
    + CONVERT(VARCHAR(36), @ExecucaoID);

-- Retorna o identificador para facilitar a consulta da auditoria.
SELECT @ExecucaoID AS ExecucaoID;
