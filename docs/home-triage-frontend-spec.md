# Home Triage - Especificacao Front

Data de referencia: `2026-07-12`.

Status: planejamento. Depende da evolucao aditiva de
`GET /api/v1/dashboard/home`.

## Objetivo

Reposicionar a Home como central de triagem diaria sem remover o dashboard real
existente antes do backend entregar `data.triage`.

## Layout alvo

- cabecalho do dia;
- prioridades de hoje;
- proximos prazos;
- itens para retomar;
- agenda imediata;
- acoes rapidas.

## Regras

- maximo 5 itens por grupo;
- secoes vazias ficam compactas;
- item sem permissao simplesmente nao aparece;
- clique abre origem canonica;
- graficos so permanecem se conduzirem a acao.

## Estados

- loading com estrutura estavel;
- vazio de triagem;
- erro com tentar novamente;
- parcial quando dashboard antigo existir mas `triage` ainda nao vier;
- sem permissao sem revelar conteudo.

## Criterio de aceite

- prioridade principal entendida em ate 5 segundos em teste;
- origem abre em ate 2 interacoes;
- dashboard antigo nao quebra se `triage` vier ausente;
- front nao calcula prazos legais.
