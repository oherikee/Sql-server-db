/*
    01_schema.sql
    Cria o modelo de demonstração do benchmark.
    Execute em um banco de testes.
*/
SET NOCOUNT ON;
GO

IF OBJECT_ID('dbo.Benchmark_Auditoria', 'U') IS NOT NULL
    DROP TABLE dbo.Benchmark_Auditoria;
GO

IF OBJECT_ID('dbo.Benchmark_Cenarios', 'U') IS NOT NULL
    DROP TABLE dbo.Benchmark_Cenarios;
GO

IF OBJECT_ID('dbo.Pedidos', 'U') IS NOT NULL
    DROP TABLE dbo.Pedidos;
GO

IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL
    DROP TABLE dbo.Clientes;
GO

CREATE TABLE dbo.Clientes
(
    ClienteID INT NOT NULL CONSTRAINT PK_Clientes PRIMARY KEY,
    Nome      VARCHAR(100) NOT NULL
);
GO

CREATE TABLE dbo.Pedidos
(
    PedidoID   BIGINT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Pedidos PRIMARY KEY,
    ClienteID  INT NOT NULL,
    DataPedido DATE NOT NULL,
    Valor      DECIMAL(12,2) NOT NULL,
    Status     VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Pedidos_Clientes
        FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID)
);
GO

CREATE INDEX IX_Pedidos_ClienteID
    ON dbo.Pedidos(ClienteID)
    INCLUDE (DataPedido, Valor, Status);
GO

CREATE TABLE dbo.Benchmark_Cenarios
(
    CenarioID  INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Benchmark_Cenarios PRIMARY KEY,
    Descricao  VARCHAR(150) NOT NULL,
    Parametro  INT NOT NULL,
    Ativo      BIT NOT NULL
        CONSTRAINT DF_Benchmark_Cenarios_Ativo DEFAULT (1)
);
GO

CREATE TABLE dbo.Benchmark_Auditoria
(
    AuditoriaID          BIGINT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Benchmark_Auditoria PRIMARY KEY,
    ExecucaoID           UNIQUEIDENTIFIER NOT NULL,
    CenarioID            INT NOT NULL,
    Parametro            INT NOT NULL,
    DataInicio           DATETIME2(3) NOT NULL,
    DataFim              DATETIME2(3) NULL,
    DuracaoMs            BIGINT NULL,
    RegistrosRetornados  BIGINT NULL,
    Status               VARCHAR(20) NOT NULL,
    ErroNumero           INT NULL,
    ErroMensagem         NVARCHAR(4000) NULL,
    CONSTRAINT FK_Benchmark_Auditoria_Cenarios
        FOREIGN KEY (CenarioID)
        REFERENCES dbo.Benchmark_Cenarios(CenarioID)
);
GO

CREATE INDEX IX_Benchmark_Auditoria_ExecucaoID
    ON dbo.Benchmark_Auditoria(ExecucaoID, CenarioID);
GO

CREATE OR ALTER FUNCTION dbo.fn_ConsultarPedidos
(
    @ClienteID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.PedidoID,
        p.ClienteID,
        p.DataPedido,
        p.Valor,
        p.Status
    FROM dbo.Pedidos AS p
    WHERE p.ClienteID = @ClienteID
);
GO
