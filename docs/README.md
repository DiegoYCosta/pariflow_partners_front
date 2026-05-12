# Documentacao do Front

Data de referencia: `2026-05-12`.

Esta pasta foi consolidada para reduzir documentos pequenos e duplicados. O
runbook operacional agora concentra ambiente, Firebase, sessao, integracao com
backend, deploy AWS e smoke tests.

## Ordem de Leitura

1. [Estado atual e proximos passos](current-implementation-status.md)
2. [Guia operacional, seguranca e deploy](guia-operacional-ambientes-e-funcoes.md)
3. [Consolidacao arquitetural do front](front-architecture-consolidation.md)
4. [Calendario compartilhado, lembretes e relatorios](calendario-compartilhado-e-relatorios.md)
5. [Contrato relacional de Network](relational-graph-contract.md)
6. [Design system CRM](new-ui-design-system.md)
7. [Icones e moldes](icones-moldes.md)

## Fontes de Verdade

- Dominio de negocio: `D:\DEV\flutter\JOTABE\DPPRO_JOTABE\Documentação`
- Backend: `D:\DEV\flutter\JOTABE\PariFlow Partners - Back`
- Front real: `lib/`
- Deploy: `D:\DEV\flutter\JOTABE\deploy_pfp_aws.ps1` e `.sh`
- Checklist AWS do backend: `../PariFlow Partners - Back/docs/aws-security-checklist.md`

## Estado Atual Resumido

| Area | Estado |
| --- | --- |
| Shell CRM | ativo |
| Companies | lista, detalhe e CRUD conectados a API real |
| Clients | lista, detalhe e CRUD conectados a API real; relacoes ainda podem cruzar contratos no front |
| Contracts | CRUD de contratos, tipos, modelos, servicos, postos e documentos |
| People | CRUD de pessoa, vinculos, ocorrencias e anexos; leitura de tags/anexos por ACL |
| Focus Board/Agenda | hub contextual com lembretes por pessoa e criacao em `POST /api/v1/agenda` |
| Relatorios | Central de Relatorios integrada a `POST /api/v1/relatorios/executar`, incluindo `controls_calendar` |
| Network | consome `GET /api/v1/network/graph` |
| Auth | `dev-token` so funciona em localhost com opt-in; host publico exige Firebase Admin real |
| Mocks | removidos de `lib/` e fora do bundle publicado |
| AWS | homologacao por IP ativa, Swagger off, bypass off, seed sample off |

## Pendencias Reais

1. Configurar dominio e HTTPS.
2. Configurar Firebase Admin na EC2 e criar usuarios reais.
3. Rodar smoke de login real ponta a ponta.
4. Trocar `COOKIE_SECURE=true` quando houver HTTPS.
5. Fechar storage privado, download rastreavel e step-up sensivel.
6. Integrar o front ao refresh/logout do backend quando a UX de sessao for
   fechada.
7. Fechar sensitive-session/step-up.
8. Evoluir a agenda atual para calendario compartilhado com feriados/dias nao
   uteis configuraveis, comunicados por grupo e filtros avancados estilo CMNET.
9. Validar CRUDs, relatorios, calendario e Network com dados reais de
   homologacao.
