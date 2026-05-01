# Documentacao do Front

## Objetivo

Esta pasta organiza o planejamento e a implementacao do frontend Flutter do PariFlow Partners sem quebrar o contrato ja definido no backend e sem duplicar regra critica de negocio na interface.

## Fontes de verdade

1. Produto e dominio: [documentacao mestre](<../../DPPRO_JOTABE/Documentação/index.html>)
2. Backend e integracao: [preparacao-backend-e-integracao-front.md](<../../PariFlow Partners - Back/docs/preparacao-backend-e-integracao-front.md>)
3. Contrato em execucao: Swagger do backend em `/api/docs`
4. Decisoes do front: arquivos desta pasta

## Plataformas alvo

- Flutter Web
- Flutter Android

## Stack considerada nesta documentacao

| Area | Tecnologia | Status | Observacao |
| --- | --- | --- | --- |
| Runtime | Flutter + Dart 3.11 | ja presente | base atual do projeto |
| Design system | Material 3 adaptado | proposto | uma base unica para web e android |
| Estado | `flutter_riverpod` | proposto | separa estado de interface, sessao e dados remotos |
| Navegacao | `go_router` | proposto | rotas declarativas e guards de sessao |
| HTTP | `dio` | proposto | interceptors, timeout, traceId e tratamento uniforme de erro |
| Serializacao | `freezed`, `json_serializable`, `build_runner` | proposto | modelos imutaveis e parse previsivel |
| Autenticacao | `firebase_core`, `firebase_auth` | proposto e alinhado ao back | troca `Firebase ID Token` por sessao interna |
| Datas e locale | `intl` | proposto | exibicao local sobre datas `ISO 8601` da API |
| Testes | `flutter_test`, `integration_test`, `mocktail` | proposto | cobertura de widget, fluxo e contratos |
| Cookies mobile | `dio_cookie_manager` + `cookie_jar` | pendente | so se o refresh continuar dependente de cookie no Android |

Nada desta pasta adiciona dependencias ainda. O objetivo aqui e fixar a direcao tecnica antes da implementacao.

## Ordem de leitura

1. [Planejamento funcional](front-planning.md)
2. [Conceito de layout inicial](front-layout-concept.md)
3. [Estrategia de migracao do novo layout](layout-migration-strategy.md)
4. [Briefing operacional da migracao](layout-migration-execution-brief.md)
5. [Backlog priorizado da migracao](layout-migration-backlog.md)
6. [Matriz `as-is -> to-be`](layout-as-is-to-be-matrix.md)
7. [Worklist de codigo do front](front-migration-code-worklist.md)
8. [Arquitetura Flutter](front-architecture.md)
9. [Plano de componentizacao](front-componentization-plan.md)
10. [Integracao com backend](front-backend-integration.md)
11. [Roadmap de implementacao](front-implementation-roadmap.md)
12. [Contrato relacional da teia](relational-graph-contract.md)
13. [Design system do shell novo](new-ui-design-system.md)
14. [Plano de evolucao de API](api-evolution-plan.md)

## Estado atual da teia

Para a teia relacional, a referencia canônica deixa de ser o prototipo antigo do repositorio e passa a ser:

- o material de `D:\DEV\flutter\JOTABE\JOTABE LAYOUT`;
- o mockup `Relational Network / Business Overview` anexado na conversa em `2026-05-01`;
- o contrato consolidado em `relational-graph-contract.md`.

Decisao operacional atual:

- a documentacao da teia pode continuar evoluindo;
- o contrato de API da teia pode continuar sendo refinado;
- o codigo atual de `lib/features/network/` nao deve ser reinterpretado como implementacao final da nova malha;
- ate segunda ordem, a teia nova fica em **congelamento de codigo** e **evolucao documental**, para evitar que a UI ande na frente do contrato relacional e do backend.

## Regras que nao podem quebrar

- O backend continua sendo `API-first`; o front nao vira fonte de regra de negocio.
- A interface consome `publicId`, nunca ID interno de banco.
- Permissoes, visibilidade sensivel e step-up de seguranca sao respeitados, nao inferidos.
- O front trata o envelope padrao de sucesso e erro em todos os modulos.
- Web e Android compartilham dominio, modelos e casos de uso; diferencas ficam confinadas a infraestrutura e adaptacao de plataforma.
- Se o contrato mudar, a documentacao daqui deve ser atualizada no mesmo movimento.

## Regra adicional de anotacoes sensiveis

O produto tambem precisa suportar anotacoes operacionais curtas sobre empresas e colaboradores, mesmo quando essas observacoes fogem do eixo tradicional de documentos formais.

Essas anotacoes seguem estas regras:

- a criacao pode acontecer sem login, como envio de tag ou observacao curta;
- a consulta exige sessao autenticada por se tratar de dado sensivel;
- cada anotacao entra como tag independente, com cor configuravel e ordem de exibicao editavel;
- cada tag de anotacao aceita ate `350` caracteres;
- o recurso continua sujeito a `CRUD`, auditoria e regras de visibilidade do backend;
- mesmo no envio anonimo, o contrato precisa carregar `ownerUserPublicId`, grupos permitidos e pessoas especificas permitidas;
- o front nao pode vazar contagem, existencia, titulo ou resumo de conteudo protegido para quem nao tiver acesso;
- a autoria define se o conteudo fica privado, compartilhado com grupos como Diretoria, Supervisao ou Auxiliares, ou liberado para pessoas especificas;
- anexos precisam nascer classificados entre documento formal, anexo sensivel e referencia de apoio;
- tags sensiveis precisam nascer classificadas entre sinal comportamental, contexto de rotina, contexto pessoal, contexto familiar, habilidade ou risco operacional.
