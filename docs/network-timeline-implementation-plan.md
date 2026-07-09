# Network Timeline Implementation Plan

Data de referencia: `2026-05-16`.

Este documento planeja a implementacao no Flutter da timeline multicamadas da
Network. O front deve consumir somente contrato backend documentado e manter o
grafo atual funcionando durante toda a migracao.

## Regras obrigatorias

- Nao substituir `GET /api/v1/network/graph` antes da timeline estar validada.
- Nao montar timeline a partir de `nodes` e `edges` do grafo.
- Nao inferir relacoes de movimento a partir de texto livre.
- Nao introduzir mock como fallback de runtime.
- Nao alterar `.env.front.example`, `.env.front.preview` ou scripts de deploy
  para facilitar testes.
- Chave omitida preserva configuracao existente em preferencias.
- Se o backend divergir de `network-timeline-read-model-plan.md`, parar e
  reportar o conflito antes de adaptar o front.
- Nao fazer refatoracoes paralelas fora de Network, modelos de Network e docs.

## Fontes de verdade

- Contrato atual do grafo: `docs/relational-graph-contract.md`
- Novo contrato backend: `PariFlow Partners - Back/docs/network-timeline-read-model-plan.md`
- Sistema visual: `docs/sistema-visual-de-cores-e-formas.md`
- Codigo atual de Network: `lib/features/network/`
- Timeline operacional mensal: `lib/features/timeline/timeline_feature.dart`
- Fixture oficial: `PariFlow Partners - Back/docs/network-timeline-payload-example.json`

O front pode criar uma copia local da fixture apenas para testes automatizados.
Essa copia deve ser tratada como derivada da fixture do backend, nunca como nova
fonte de contrato.

## Decisao de produto e arquitetura

A tela de Network passa a ter dois modos:

```text
Timeline
Atual
```

`Timeline` mostra contratos, postos, colaboradores, alocacoes e eventos no eixo
X temporal. `Atual` usa o mesmo payload para exibir a hierarquia ativa na data
de referencia.

O grafo relacional atual continua existindo como modo legado/relacional ate a
nova experiencia provar paridade operacional. Ele nao deve ser apagado no
primeiro ciclo.

## Contrato consumido

Endpoint esperado:

```text
GET /api/v1/network/timeline
```

O parser deve aceitar o envelope real `{ data, meta }`. Aceitar `data` direto
pode continuar permitido apenas para fixtures e testes locais, como ja acontece
com o grafo.

Parametros enviados pelo front:

- `periodPreset`
- `from`
- `to`
- `focusCompanyPublicId`
- `focusCompanyType`
- `rootCompanyPublicIds`
- `clientCompanyPublicIds`
- `contractStatuses`
- `employeeStatuses`
- `includeHistorical`
- `includeMoves`
- `includeOperationalEvents`
- `search`

O front nao deve enviar parametros de tenant.

## Matriz de compatibilidade

| Superficie | Regra de compatibilidade |
| --- | --- |
| Network relacional | `loadGraph` e parser de `_NetworkGraphPayload` permanecem intactos |
| Network timeline | `loadTimeline` e modelos novos ficam separados do grafo |
| Modo atual | Usa o payload timeline, nao endpoints de CRUD avulsos |
| Timeline mensal | `lib/features/timeline/timeline_feature.dart` nao deve ser alterada no primeiro ciclo |
| Identidade visual | Reaproveitar componentes atuais; backend persistido so quando existir contrato |
| Preferencias | Updates parciais preservam chaves omitidas |
| Runtime real | Falha de API mostra erro, sem fixture/mock |
| `.env.front.*` | Sem alteracao obrigatoria |
| AWS preview | Continua usando base `/api/v1` existente |
| Android/Web | Sem configuracao nova no primeiro ciclo |

## Modelos Dart novos

Criar modelos separados dos modelos de grafo:

- `_NetworkTimelinePayload`
- `_NetworkTimelinePeriod`
- `_NetworkTimelineFocus`
- `_NetworkTimelineContract`
- `_NetworkTimelinePosition`
- `_NetworkTimelineAllocation`
- `_NetworkTimelineCollaborator`
- `_NetworkTimelineSegment`
- `_NetworkTimelineEvent`
- `_NetworkTimelineCurrentSnapshot`
- `_NetworkTimelineFilters`
- `_NetworkTimelineWarning`

Esses modelos devem ficar no recorte de Network, mantendo a convencao atual de
part files se a feature continuar agregada em `app.dart`.

## Repository

Adicionar em `_NetworkApiRepository`:

```dart
Future<_NetworkTimelinePayload> loadTimeline(...)
```

Regras:

- manter `loadGraph` intacto;
- carregar identidades visuais necessarias antes de retornar dados;
- em erro de API, retornar estado indisponivel sem mock;
- mensagem de erro deve mencionar `/network/timeline`;
- query lists seguem a mesma normalizacao de `_networkQueryList`.

## Estado de UI

Adicionar estado local:

- modo selecionado: timeline, atual, relacional;
- periodo;
- busca;
- foco;
- filtros de status;
- include historical;
- include moves;
- include operational events;
- zoom;
- item selecionado;
- lane/camada selecionada;
- warnings visiveis.

Preferencias so devem ser persistidas se seguirem o padrao ja usado pelo front.
Se houver update parcial de preferencias, campos omitidos preservam o restante.

## Renderizacao da timeline

Criar um widget dedicado:

```text
_NetworkTimelineCanvas
```

Camadas do canvas:

1. Grid temporal e cabecalho de meses/anos.
2. Contratos.
3. Postos.
4. Colaboradores.
5. Conexoes de alocacao.
6. Eventos.
7. Selecoes e hover.

Usar:

- `InteractiveViewer`
- `TransformationController`
- `CustomPainter`
- `RepaintBoundary`
- culling por viewport

Nao usar widget card para cada item quando o volume ficar alto. Cards podem ser
usados no painel lateral, lista de detalhes e estado atual; a timeline principal
deve priorizar Canvas.

## Culling e performance

O painter deve calcular o viewport em coordenadas de cena e ignorar:

- barras fora do intervalo X visivel;
- linhas cujos pontos inicial e final estejam fora do viewport;
- labels quando o zoom nao permitir leitura;
- padroes visuais complexos em zoom distante.

Metas iniciais:

- 120 contratos;
- 500 postos;
- 3000 alocacoes;
- pan/zoom sem travamento perceptivel;
- nenhuma chamada de API durante pan/zoom.

Se esses volumes nao forem sustentados, parar e propor agrupamento/clusterizacao
antes de reduzir fidelidade do modelo.

## Estado atual

Criar uma visao hierarquica com o mesmo payload:

```text
Prestadora/cliente foco
Contrato ativo
Posto ativo
Colaboradores ativos
```

Regras:

- usar somente segmentos ativos na data `period.to`;
- nao esconder historico no payload, apenas na apresentacao;
- manter acesso ao detalhe de contrato, posto e pessoa;
- nao reconsultar endpoints de CRUD para montar a arvore inicial.

## Identidade visual

Reaproveitar:

- `_EntityMarker`
- `_EntityBadge`
- `_EntityChip`
- `_VisualIdentityLegend`
- `EntityVisualIdentity`
- `VisualIdentityLocalStore` enquanto o backend ainda nao persistir identidade.

Quando o backend persistir `visual_identities`, o front deve preferir a
identidade recebida da API e manter o cache local apenas como fallback ou
preferencia temporaria documentada.

## UX minima

Controles:

- busca;
- periodos rapidos;
- intervalo customizado;
- toggle Timeline/Atual/Relacional;
- filtro por prestadora/cliente;
- filtro por status de contrato;
- filtro por status de colaborador;
- include historical;
- include moves;
- include operational events;
- reset de viewport;
- centralizar no foco;
- legenda.

Painel lateral:

- detalhe de contrato;
- detalhe de posto;
- detalhe de colaborador;
- detalhe de evento;
- warnings de dado incompleto;
- CTA existente quando houver rota segura.

## Implementacao por fases

### Fase 0 - Contrato bloqueante

- Backend documentado e aprovado.
- Fixture realista do payload timeline.
- Parser Dart com testes.
- Nenhuma mudanca visual ainda.

### Fase 1 - Consumo seguro

- `loadTimeline`.
- Estado de runtime separado do grafo.
- Tratamento de erro sem mock.
- Testes de parser, erro e payload vazio.

### Fase 2 - Canvas base

- eixo temporal;
- contratos;
- postos;
- colaboradores;
- selecao simples;
- painel lateral simples.

### Fase 3 - Eventos e conexoes

- alocacoes;
- admissoes;
- desligamentos;
- movimentos somente com ids estruturados;
- warnings quando evento nao puder ser ligado com seguranca.

### Fase 4 - Estado atual

- arvore ativa;
- filtros compartilhados;
- comparacao com grafo atual para validar contagens.

### Fase 5 - Acabamento e volume

- culling completo;
- labels por zoom;
- legenda final;
- responsividade;
- validacao com dados reais.

## Checklist por PR

### PR 1 - Parser e fixture de teste

- Criar modelos Dart da timeline.
- Adicionar testes de parse com fixture derivada da oficial do backend.
- Aceitar envelope `{ data, meta }` e objeto `data` direto em fixture.
- Nao alterar UI.

### PR 2 - Repository e estado runtime

- Adicionar `loadTimeline`.
- Manter `loadGraph` sem alteracao comportamental.
- Criar estado de erro/loading separado.
- Garantir que erro nao carrega mock.

### PR 3 - Shell de modos

- Adicionar toggle Timeline/Atual/Relacional.
- Relacional continua como caminho funcional atual.
- Timeline pode abrir estado vazio/indisponivel com mensagem clara.
- Sem remover filtros existentes.

### PR 4 - Canvas base

- Implementar eixo temporal, contratos, postos e colaboradores.
- Implementar selecao e painel lateral basico.
- Testar escala temporal e segmentos abertos.

### PR 5 - Eventos, conexoes e warnings

- Renderizar eventos.
- Desenhar conexoes apenas quando houver ids estruturados.
- Exibir warning para movimento textual.
- Testar ausencia de conexao posicional em evento incompleto.

### PR 6 - Modo atual

- Montar arvore ativa a partir de `currentSnapshot`.
- Validar contagens contra payload timeline.
- Nao chamar endpoints de CRUD para reconstruir a arvore inicial.

### PR 7 - Performance e regressao

- Adicionar culling.
- Validar volumes-alvo.
- Rodar analyze/test/build web.
- Smoke manual do grafo relacional atual.

Status em `2026-07-09`:

- culling por viewport existe no painter para ticks, labels, barras, eventos e
  conexoes estruturadas;
- teste automatizado `network_timeline_payload_test.dart` valida layout e
  culling com 120 contratos, 500 postos, 3000 alocacoes e movimentos
  estruturados;
- smoke externo sem token valida que `/network/graph` e `/network/timeline`
  continuam publicados e protegidos;
- ainda falta smoke autenticado visual com dados reais e medicao manual de
  fluidez em navegador.

## Testes obrigatorios

Flutter:

- `flutter analyze`
- `flutter test`
- `flutter build web --release` antes de publicar preview

Testes unitarios a criar junto da implementacao:

- parse de payload envelopado;
- parse de `data` direto para fixture;
- payload vazio;
- campos extras preservados quando necessario;
- warning de movimento textual sem ids;
- calculo de escala temporal;
- segmento aberto com `endsAt=null`;
- filtro de estado atual na data `period.to`;
- culling de barras fora do viewport;
- selecao de item e detalhe lateral;
- ausencia de mock em erro de API.

Smoke manual:

- Network relacional atual continua abrindo com `/network/graph`.
- Timeline abre com `/network/timeline`.
- Erro de API exibe estado indisponivel, nao dados falsos.
- Android/Web continuam sem alteracao de ambiente.
- Preview AWS usa a mesma base `/api/v1`.

## Pontos de parada

Parar e reportar se:

- backend retornar campos fora do contrato documentado;
- timeline exigir inferir movimentacao por texto;
- volume real exigir simplificar modelo de dados;
- alguma mudanca pedir alteracao de `.env` ou deploy AWS nao documentada;
- o grafo atual quebrar durante a implementacao;
- identidade visual persistida no backend entrar em conflito com cache local.

## Criterios de aceite

- Sem regressao no fluxo atual de Network.
- Sem reintroduzir legado como autoridade da timeline.
- Sem simplificacao que reduza fidelidade da modelagem.
- Sem alterar funcionalidades fora do escopo.
- Front e back documentados antes do codigo consumir o novo contrato.
- Timeline e estado atual usam o mesmo read model.
- Movimentos imprecisos aparecem como warning, nao como relacao desenhada.
