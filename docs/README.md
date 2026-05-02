# Documentacao do Front

## Objetivo

Esta pasta organiza o estado atual, os contratos e o backlog remanescente do frontend Flutter do PariFlow Partners.

O front ja nao esta em fase puramente conceitual. Parte importante do shell novo, dos modulos mestre, de `People` e do preview relacional ja existe no codigo. Por isso, os documentos daqui devem ser lidos em duas categorias:

- estado atual e decisao operacional;
- historico, estrategia e backlog de evolucao.

## Leitura inicial obrigatoria - Não incluídas no commit público

1. [Estado atual de implementacao](current-implementation-status.md)
2. [Conceito de layout](front-layout-concept.md)
3. [Integracao com backend](front-backend-integration.md)
4. [Plano de evolucao de API](api-evolution-plan.md)
5. [Matriz `as-is -> to-be`](layout-as-is-to-be-matrix.md)
6. [Worklist remanescente do front](front-migration-code-worklist.md)

Os demais documentos continuam validos como apoio arquitetural, estrategia de rollout ou historico da migracao.

## Fontes de verdade

1. Produto e dominio: pasta compartilhada `DPPRO_JOTABE`
2. Backend tecnico: `../../PariFlow Partners - Back/docs/preparacao-backend-e-integracao-front.md`
3. Contrato em execucao: Swagger do backend em `/api/docs`
4. Estado real do front: codigo em `lib/`
5. Consolidacao documental do estado atual: `current-implementation-status.md`

## Plataformas alvo

- Flutter Web
- Flutter Android

## Stack real do repositorio x direcao documentada

| Area | Hoje no repo | Direcao documentada | Leitura correta |
| --- | --- | --- | --- |
| Runtime | Flutter + Dart 3.11 | mantido | estado real |
| Design system | Material/tema customizado local | evolucao guiada pelo shell CRM | parcial |
| Estado | estado local/manual | `flutter_riverpod` continua apenas como direcao | ainda nao implantado |
| Navegacao | shell e composicao locais | `go_router` continua apenas como direcao | ainda nao implantado |
| HTTP | ainda nao centralizado no front | `dio` continua apenas como direcao | ainda nao implantado |
| Serializacao | parse/modelos manuais | `freezed` e `json_serializable` continuam como direcao | ainda nao implantado |
| Auth no front | ainda sem runtime completo no app Flutter | Firebase + sessao interna continua sendo a trilha alvo | parcialmente documentado, nao operacional no front |
| Testes | base Flutter padrao | ampliar para widget/integracao depois | inicial |

## Estado atual do shell e dos modulos

- `legacy_shell` e `crm_shell` ja existem.
- A variante ativa hoje e `crm`.
- O dashboard CRM ja esta implantado.
- `Companies`, `Client Companies`, `Contracts`, `People` e `Network` ja possuem features dedicadas.
- `People` ja trabalha com `Employment Links`, bloco sensivel e anexos.
- `Network` ja possui leitura em quatro faixas, legenda, periodo, busca e painel lateral, mas ainda opera com payload de preview.

## Estado atual da teia

A referencia visual canonica da teia passa a ser:

- o material de `JOTABE LAYOUT`;
- o mockup `Relational Network / Business Overview` anexado em `2026-05-02`;
- o contrato consolidado em `relational-graph-contract.md`;
- a implementacao intermediaria existente em `lib/features/network/presentation/network_workspace.dart`.

Leitura correta:

- o codigo atual da teia e reaproveitavel e ja embute conceitos corretos de `lanes`, legenda e painel lateral;
- ele ainda nao deve ser tratado como contrato final;
- o principal bloqueador remanescente continua sendo o endpoint backend canonico da malha.

## Regras que nao podem quebrar

- O backend continua sendo `API-first`.
- A interface consome `publicId`, nunca ID interno de banco.
- Permissoes, visibilidade sensivel e step-up de seguranca sao respeitados, nao inferidos.
- O front trata o envelope padrao de sucesso e erro em todos os modulos.
- Web e Android compartilham dominio, modelos e casos de uso; diferencas ficam confinadas a infraestrutura e adaptacao de plataforma.
- Se o contrato mudar, a documentacao daqui deve ser atualizada no mesmo movimento.

## Regra adicional de anotacoes sensiveis

O produto precisa suportar anotacoes operacionais curtas sobre empresas e colaboradores, mesmo quando essas observacoes fogem do eixo de documentos formais.

Essas anotacoes seguem estas regras:

- a criacao pode acontecer sem login, como envio de tag ou observacao curta;
- a consulta exige sessao autenticada por se tratar de dado sensivel;
- cada anotacao entra como tag independente, com cor configuravel e ordem de exibicao editavel;
- cada tag aceita ate `350` caracteres;
- o recurso continua sujeito a `CRUD`, auditoria e regras de visibilidade do backend;
- mesmo no envio anonimo, o contrato precisa carregar `ownerUserPublicId`, grupos permitidos e pessoas especificas permitidas;
- o front nao pode vazar contagem, existencia, titulo ou resumo de conteudo protegido para quem nao tiver acesso;
- anexos precisam nascer classificados entre documento formal, anexo sensivel e referencia de apoio;
- tags sensiveis precisam nascer classificadas entre sinal comportamental, contexto de rotina, contexto pessoal, contexto familiar, habilidade ou risco operacional.
