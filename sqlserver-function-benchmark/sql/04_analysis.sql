/*
    04_analysis.sql
    Informe o ExecucaoID retornado pelo script 03.
*/
DECLARE @ExecucaoID UNIQUEIDENTIFIER = NULL;
-- Exemplo:
-- SET @ExecucaoID = '00000000-0000-0000-0000-000000000000';

SELECT
    a.ExecucaoID,
    c.Descricao,
    a.Parametro,
    a.DataInicio,
    a.DataFim,
    a.DuracaoMs,
    a.RegistrosRetornados,
    a.Status,
    a.ErroNumero,
    a.ErroMensagem
FROM dbo.Benchmark_Auditoria AS a
INNER JOIN dbo.Benchmark_Cenarios AS c
    ON c.CenarioID = a.CenarioID
WHERE @ExecucaoID IS NULL
   OR a.ExecucaoID = @ExecucaoID
ORDER BY a.DataInicio, a.CenarioID;

-- Resumo por cenário, útil para comparar repetições.
SELECT
    c.Descricao,
    a.Parametro,
    COUNT_BIG(*) AS TotalExecucoes,
    MIN(a.DuracaoMs) AS MenorDuracaoMs,
    AVG(CONVERT(DECIMAL(18,2), a.DuracaoMs)) AS MediaDuracaoMs,
    MAX(a.DuracaoMs) AS MaiorDuracaoMs,
    AVG(CONVERT(DECIMAL(18,2), a.RegistrosRetornados))
        AS MediaRegistros
FROM dbo.Benchmark_Auditoria AS a
INNER JOIN dbo.Benchmark_Cenarios AS c
    ON c.CenarioID = a.CenarioID
WHERE a.Status = 'SUCESSO'
  AND (@ExecucaoID IS NULL OR a.ExecucaoID = @ExecucaoID)
GROUP BY c.Descricao, a.Parametro
ORDER BY a.Parametro;
