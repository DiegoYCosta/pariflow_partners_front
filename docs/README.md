# Documentacao do Front

Data de referencia: `2026-05-14`.

Esta pasta consolida a documentacao viva do front Flutter. Ela reduz duplicacao
entre documentos externos e o repositorio, mantendo um indice direto para o que
importa na realidade atual do produto.

## Ordem de leitura

1. [README do front](../README.md)
2. [Estado atual e proximos passos](current-implementation-status.md)
3. [Guia operacional, seguranca e deploy](guia-operacional-ambientes-e-funcoes.md)
4. [Consolidacao arquitetural do front](front-architecture-consolidation.md)
5. [Calendario, Timeline e relatorios](calendario-compartilhado-e-relatorios.md)
6. [Workspaces operacionais](operational-entity-workspaces.md)
7. [Contrato relacional de Network](relational-graph-contract.md)
8. [Network Timeline Implementation Plan](network-timeline-implementation-plan.md)
9. [Design system CRM](new-ui-design-system.md)
10. [Sistema visual de cores e formas](sistema-visual-de-cores-e-formas.md)
11. [Icones e moldes](icones-moldes.md)

## Fontes de verdade

- Codigo real: `lib/`
- API: `D:\DEV\flutter\JOTABE\PariFlow Partners - Back`
- Documentacao de produto: `D:\DEV\flutter\JOTABE\DPPRO_JOTABE\Documentacao`
- Deploy: `D:\DEV\flutter\JOTABE\deploy_pfp_aws.ps1` e `.sh`
- Ambiente: `.env.front.example` e `.env.front.preview`

## Estado atual resumido

| Area | Estado |
| --- | --- |
| Shell CRM | ativo como variante principal |
| Home | dashboard real, sem mock silencioso |
| Companies/Clients/Contracts | CRUDs reais conectados a API |
| People | CRUD de pessoa, vinculos, ocorrencias, anexos, agenda e Focus Board |
| Focus Board | persistente, acoplavel/desacoplavel, alimentada pela API |
| Timeline | calendario operacional com agenda, dias nao uteis e registros |
| Relatorios | central integrada a `POST /api/v1/relatorios/executar` |
| Network | grafo real via `GET /api/v1/network/graph` |
| Auth | Firebase real em host publico; `dev-token` so local |
| Perfil | `GET/PATCH /auth/me`, preferencias, calendario e onboarding interno |
| Mocks | fora do runtime real e do bundle publicado |

## Pendencias reais

1. Dominio e HTTPS.
2. Usuarios reais, perfis internos e smoke de login real.
3. UX final de refresh/logout.
4. Storage privado, step-up e download rastreavel.
5. Persistencia backend de identidade visual.
6. Preview de audiencia e ciencia no calendario.
7. Exportacao/auditoria final de relatorios.
8. Validacao responsiva com dados reais.
