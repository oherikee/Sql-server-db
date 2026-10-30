# SQL Server Function Benchmark

Pequeno laboratório para comparar o comportamento de uma função no SQL Server usando diferentes parâmetros.

O projeto demonstra como:

- cadastrar cenários de teste;
- executar uma função para cada conjunto de parâmetros;
- auditar início, fim, duração, quantidade de linhas e erros;
- coletar planos reais e estatísticas de IO/tempo no SSMS;
- comparar os cenários e investigar possíveis gargalos.

> **Importante:** este repositório é um laboratório didático. `STATISTICS IO` e `STATISTICS TIME` são apresentados na aba **Messages** do SSMS e não são gravados automaticamente na tabela de auditoria. Os planos reais também devem ser capturados pelo SSMS ou por uma estratégia específica de Extended Events. O projeto não afirma persistir essas métricas automaticamente.

## Requisitos

- SQL Server 2017 ou superior (o exemplo usa `CREATE OR ALTER FUNCTION`);
- SQL Server Management Studio (SSMS) ou Azure Data Studio;
- permissão para criar tabelas, funções e inserir dados no banco de testes.

## Estrutura

```text
sqlserver-function-benchmark/
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   ├── 03_run_benchmark.sql
│   └── 04_analysis.sql
├── docs/
│   └── methodology.md
├── .gitignore
├── LICENSE
└── README.md
```

## Como executar

Execute os scripts na ordem abaixo, em um **banco de testes**:

1. `sql/01_schema.sql` — cria as tabelas e a função de exemplo.
2. `sql/02_seed.sql` — insere dados fictícios e cenários.
3. `sql/03_run_benchmark.sql` — percorre os cenários e registra a auditoria.
4. `sql/04_analysis.sql` — consulta e compara os resultados.

No SSMS, antes de executar `03_run_benchmark.sql`:

1. Ative **Include Actual Execution Plan** (`Ctrl + M`).
2. Mantenha a aba **Messages** aberta.
3. Execute o script e observe os resultados e as mensagens de `STATISTICS IO` / `STATISTICS TIME`.

O script executa cada cenário como uma instrução `SELECT` separada. Isso facilita a inspeção do plano real de cada execução. O resultado da função é retornado ao cliente; por isso, o volume de resultados também pode influenciar o tempo decorrido.

## O que é auditado

A tabela `dbo.Benchmark_Auditoria` registra:

- identificador da rodada (`ExecucaoID`);
- cenário e parâmetro utilizado;
- horário de início e término;
- duração aproximada em milissegundos;
- quantidade de linhas retornadas;
- status e detalhes de erro.

A duração registrada mede o intervalo observado pelo script em torno do `SELECT`. Ela não substitui o tempo de CPU nem as métricas do mecanismo exibidas por `STATISTICS TIME`.

## Cuidados para interpretar os resultados

- Faça os testes em ambiente isolado ou controlado; não use produção sem planejamento.
- Execute cada cenário mais de uma vez e compare tendências, não apenas uma medição.
- Considere cache de dados e de planos, concorrência, carga do servidor e latência de rede.
- Não compare cenários com volumes de saída muito diferentes sem considerar o custo de transferir os resultados ao cliente.
- `STATISTICS IO/TIME` também pode refletir instruções auxiliares executadas no mesmo lote. Para análise rigorosa, isole a instrução medida ou use uma coleta apropriada.
- Um plano estimado não substitui o plano **real** quando a investigação depende de linhas efetivamente processadas.
- A função de exemplo é uma inline table-valued function (iTVF). Funções escalares e multi-statement TVFs têm características próprias e podem exigir outra estratégia de análise.

## Escopo e extensões possíveis

Este projeto é um ponto de partida. Próximas evoluções interessantes:

- persistir planos XML por cenário;
- coletar métricas com Extended Events;
- executar múltiplas repetições e calcular mediana / percentis;
- adicionar múltiplos parâmetros por cenário;
- comparar duas versões de uma função;
- exportar os resultados para CSV e montar um relatório.

Veja [`docs/methodology.md`](docs/methodology.md) para detalhes sobre a metodologia.
