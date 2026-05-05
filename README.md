# PariFlow Partners Front

Frontend Flutter do PariFlow Partners com alvo Web e Android.

## Estado Atual

O projeto ja nao esta em fundacao conceitual. O shell CRM esta ativo e os
modulos `Companies`, `Clients`, `Contracts`, `People` e `Network` possuem
features dedicadas.

O front ja possui camada HTTP propria, fallback local controlado e consumo real
de endpoints do backend para modulos operacionais. A autenticacao ainda usa
`dev-token` em preview privado, ate o login Firebase runtime entrar no app.

## Documentacao Viva

- [Indice documental](docs/README.md)
- [Guia operacional de ambientes e funcoes](docs/guia-operacional-ambientes-e-funcoes.md)
- [Firebase runtime config](docs/firebase-runtime-config.md)
- [Estado atual e proximos passos](docs/current-implementation-status.md)
- [Integracao com backend](docs/front-backend-integration.md)
- [Companies, Clients e Contracts](docs/companies-clients-contracts-layout-plan.md)
- [Contrato relacional de Network](docs/relational-graph-contract.md)
- [Design system CRM](docs/new-ui-design-system.md)
- [Icones e moldes](docs/icones-moldes.md)

## Regras de Integracao

- Toda relacao usa `publicId`, nunca ID interno.
- A API fica em `/api/v1`.
- Em build web no mesmo host do Apache, o front usa `/api/v1` automaticamente.
- Se a API ficar em outro host, buildar com
  `--dart-define=PARIFLOW_API_BASE_URL=https://dominio/api/v1`.
- Para preview local consumindo a API online, rode `scripts/dev-api-proxy.cjs`
  e aponte `PARIFLOW_API_BASE_URL` para `http://127.0.0.1:3002/api/v1`.
- Em `localhost` ou `127.0.0.1`, o app mostra um aviso fixo de preview local no
  canto superior direito. Esse aviso nao aparece em deploy publico.
- Conteudo sensivel, anexos e permissao seguem ACL do backend; o front nao
  infere acesso nem exibe metadado protegido sem autorizacao.
