# Documentacao do Front

Data de referencia: `2026-05-04`.

Esta pasta foi consolidada para manter apenas documentos que ainda orientam
trabalho ativo. Planos antigos de migracao, componentizacao e backlog inicial
foram removidos porque descreviam etapas ja executadas ou duplicavam o estado
atual.

## Ordem de Leitura

1. [Estado atual e proximos passos](current-implementation-status.md)
2. [Guia operacional de ambientes e funcoes](guia-operacional-ambientes-e-funcoes.md)
3. [Firebase runtime config](firebase-runtime-config.md)
4. [Integracao com backend](front-backend-integration.md)
5. [Companies, Clients e Contracts](companies-clients-contracts-layout-plan.md)
6. [Contrato relacional de Network](relational-graph-contract.md)
7. [Design system CRM](new-ui-design-system.md)

## Fontes de Verdade

- Dominio de negocio: `../DPPRO_JOTABE/Documentacao`
- Backend: Swagger em `/api/docs` e codigo em `../pariflow_partners_back`
- Front real: codigo em `lib/`
- Deploy e seguranca: docs do backend, principalmente
  `docs/aws-security-checklist.md`

## Estado Atual Resumido

| Area | Estado |
| --- | --- |
| Shell CRM | ativo |
| Companies | lista, detalhe e CRUD conectados a API |
| Clients | lista, detalhe e CRUD conectados a API; detalhe ainda cruza contratos no front |
| Contracts | CRUD de contratos, tipos, modelos, servicos, postos e documentos |
| People | CRUD de pessoa, vinculos, ocorrencias e anexos; leitura de tags/anexos por ACL |
| Network | consome `GET /network/graph`; ainda precisa refinamento visual/performance |
| Auth | preview usa `dev-token`; producao exige Firebase runtime no front |
| AWS | homologacao por IP ativa atras de Apache no mesmo host |

## Proximos Passos

1. Trocar preview auth por Firebase no front.
2. Configurar dominio, HTTPS e secrets de producao.
3. Fechar storage/download protegido e step-up sensivel.
4. Implementar auditoria e relatorios.
5. Refinar responsividade Web/Android e remover fallback local quando os dados
   reais estiverem consistentes.
