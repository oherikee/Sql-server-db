/*
    02_seed.sql
    Dados fictícios e cenários de teste.
*/
SET NOCOUNT ON;
GO

-- Clientes de exemplo
INSERT INTO dbo.Clientes (ClienteID, Nome)
VALUES
    (10, 'Cliente A'),
    (25, 'Cliente B'),
    (100, 'Cliente C'),
    (999, 'Cliente sem pedidos');
GO

-- Volumes diferentes para ilustrar seletividade e cardinalidade.
-- Cliente 10: poucos pedidos
INSERT INTO dbo.Pedidos (ClienteID, DataPedido, Valor, Status)
SELECT TOP (5)
    10,
    DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), CONVERT(date, GETDATE())),
    CONVERT(DECIMAL(12,2), 50 + ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
    'Concluido'
FROM sys.all_objects;
GO

-- Cliente 25: volume intermediário
INSERT INTO dbo.Pedidos (ClienteID, DataPedido, Valor, Status)
SELECT TOP (500)
    25,
    DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), CONVERT(date, GETDATE())),
    CONVERT(DECIMAL(12,2), 100 + ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 2 = 0
         THEN 'Concluido' ELSE 'Pendente' END
FROM sys.all_objects AS a
CROSS JOIN sys.all_objects AS b;
GO

-- Cliente 100: volume maior
INSERT INTO dbo.Pedidos (ClienteID, DataPedido, Valor, Status)
SELECT TOP (5000)
    100,
    DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), CONVERT(date, GETDATE())),
    CONVERT(DECIMAL(12,2), 200 + ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 2 = 0
         THEN 'Concluido' ELSE 'Pendente' END
FROM sys.all_objects AS a
CROSS JOIN sys.all_objects AS b;
GO

INSERT INTO dbo.Benchmark_Cenarios (Descricao, Parametro)
VALUES
    ('Cliente com poucos pedidos', 10),
    ('Cliente com volume intermediario', 25),
    ('Cliente com volume maior', 100),
    ('Cliente sem pedidos', 999);
GO

UPDATE STATISTICS dbo.Pedidos;
GO
