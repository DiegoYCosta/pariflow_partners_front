# Contrato Relacional de Network

Data de referencia: `2026-05-14`.

## Estado

`GET /api/v1/network/graph` e a fonte vigente do grafo relacional. O front
consome esse endpoint no runtime real e nao carrega mock/sample quando a API
falha ou retorna vazia.

O contrato publicado pelo backend e envelopado como `{ data, meta }`. O parser
do front tambem aceita o objeto `data` direto para facilitar fixtures e testes
locais.

## Modelo Visual

A Network opera como rede em faixas, nao como arvore. O backend devolve nos e
arestas do recorte; a UI pode filtrar, ocultar lanes e criar pontes visuais
locais, mas nao reconstrui a relacao de negocio a partir de listas soltas.

Lanes vigentes, na ordem visual:

1. `root_company`
2. `client_company`
3. `contract`
4. `position`
5. `employee`

`position` permanece como lane propria porque o backend modela postos/servicos
do contrato. A UI pode recolher essa camada visualmente, mas a relacao base
continua `contract -> position -> employee`.

## Endpoint

```text
GET /api/v1/network/graph
```

Query suportada pelo contrato do front:

- `periodPreset=6m|1y|2y|all`
- `search`
- `focusPublicId`
- `rootCompanyPublicIds` em CSV ou lista repetida
- `clientCompanyPublicIds` em CSV ou lista repetida
- `contractStatuses` em CSV ou lista repetida, normalizado em lowercase
- `employeeStatuses` em CSV ou lista repetida, normalizado em lowercase
- `includeHistorical`, default backend `true`
- `includeIndirect`, default backend `false`

## Payload

```json
{
  "data": {
    "period": { "preset": "1y", "from": "2025-05-14", "to": "2026-05-14" },
    "lanes": ["root_company", "client_company", "contract", "position", "employee"],
    "nodes": [],
    "edges": [],
    "filters": {},
    "legend": {},
    "focus": {}
  },
  "meta": { "traceId": "req_..." }
}
```

### Node

Campos obrigatorios por no:

- `publicId`
- `nodeType`
- `lane`
- `displayName`
- `subtitle`
- `status`
- `badges`
- `detailSnapshot`

`nodeType` e `lane` usam os mesmos valores das lanes vigentes. `status` trafega
normalizado para leitura do front (`active`, `expired`, `dismissed`, etc.).

`detailSnapshot` possui campos conhecidos pelo front e aceita extras. Extras
nao conhecidos continuam disponiveis para busca, detalhe lateral e evolucao do
contrato sem quebrar versoes antigas.

Campos conhecidos principais:

- `kind`
- `summary`
- `contractStatus`
- `activeClientCompanies`
- `activeContracts`
- `activeEmployees`
- `historicalEmployees`
- `historicalContracts`
- `indirectConnections`
- `rootCompanies`
- `clientCompanies`
- `cta`

Extras usados atualmente pelo front quando presentes:

- `providerCompany`
- `clientCompany`
- `contract`
- `position`
- `service`
- `shift`
- `schedule`
- `scale`
- `location`
- `statusLabel`
- `startDate`
- `endDate`
- `email`
- `phone`
- `cpf`
- `department`
- `manager`

### Edge

Campos obrigatorios por aresta:

- `publicId`
- `fromPublicId`
- `toPublicId`
- `relationshipKind`
- `relationshipState`
- `periodStart`
- `periodEnd`
- `metadata`

`relationshipState` controla leitura ativa, historica ou indireta:

- `active`
- `historical`
- `indirect`

Kinds emitidos atualmente pelo backend:

- `provider_client_scope`
- `contract_allocation`
- `position_scope`
- `employment_link`

Kinds locais criados apenas pela UI:

- `hidden_node_bridge`

## Regras

- O front nao assume pai unico para cliente, contrato, posto ou pessoa.
- Uma entidade pode ter multiplas arestas.
- Pessoa, colaborador, contrato, cliente e prestadora trafegam por `publicId`.
- O backend devolve o recorte inteiro de nos e arestas; o front apenas aplica
  filtros visuais e analiticos sobre esse grafo.
- Lanes ocultas no front nao removem o contexto: a UI cria pontes visuais entre
  os nos ainda visiveis.
- `includeHistorical=false` remove arestas historicas no recorte remoto e tambem
  e respeitado pelos filtros locais.
- `includeIndirect=false` remove arestas indiretas quando elas existirem.

## Fixture

O exemplo em `network-graph-payload-example.json` e documental e acompanha a
forma vigente do payload, incluindo a lane `position`. A fonte de verdade segue
sendo a API real.

## Pendente

- Validar volume real para limite, paginacao e agrupamento de colaboradores.
- Refinar foco, drill-down e retorno de contexto com usuarios reais.
- Aplicar ACL fina para metadados sensiveis do detalhe lateral.
- Alinhar CTAs definitivos por entidade quando as rotas finais forem fechadas.
