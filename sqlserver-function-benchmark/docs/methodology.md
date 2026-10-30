# Metodologia de benchmark

## Objetivo

Observar como uma mesma função se comporta quando recebe parâmetros diferentes, relacionando os resultados aos planos de execução e às métricas do SQL Server.

## Fluxo

1. Cadastrar cenários em `dbo.Benchmark_Cenarios`.
2. Executar o runner para percorrer os cenários ativos.
3. Auditar parâmetros, duração, quantidade de linhas e erros.
4. Capturar o plano real no SSMS.
5. Registrar `STATISTICS IO` e `STATISTICS TIME` apresentados em Messages.
6. Comparar os cenários e formular hipóteses.
7. Alterar uma variável por vez e repetir o benchmark.

## Interpretação

- **Logical reads:** páginas lidas do buffer pool. Valores altos podem indicar leituras excessivas, mas precisam ser interpretados junto ao plano e ao volume retornado.
- **CPU time:** tempo de CPU consumido pela execução.
- **Elapsed time:** tempo decorrido; pode incluir espera, escalonamento, transferência de resultados e outros fatores.
- **Actual rows:** quantidade efetivamente processada em operadores do plano real.
- **Estimated rows:** estimativa do otimizador. Diferenças relevantes podem apontar para problemas de estimativa/cardinalidade.

## Reprodutibilidade

Para uma comparação mais confiável:

- execute várias repetições;
- mantenha os dados e configurações constantes;
- anote versão do SQL Server, compatibilidade do banco e índices;
- controle concorrência e carga externa;
- documente se o teste foi realizado com cache aquecido ou após limpeza controlada;
- não limpe caches em ambiente compartilhado ou de produção;
- compare a mesma operação e o mesmo conjunto de colunas.

## Limitações do exemplo

O runner registra a duração observada pelo próprio script e a quantidade de linhas retornadas. `STATISTICS IO/TIME` são emitidos como mensagens do cliente, não inseridos na tabela de auditoria. O plano real é visualizado no SSMS. Automatizar a persistência dessas evidências exige uma etapa adicional, por exemplo Extended Events, Query Store ou captura controlada de planos XML.

A coleta de `query_post_execution_showplan` via Extended Events pode adicionar overhead. Deve ser usada com filtros, em ambiente de teste e por períodos curtos.
