# PariFlow Partners Front

Frontend Flutter do PariFlow Partners com alvo Web e Android.

## Estado Atual

O projeto ja nao esta em fundacao conceitual. O shell CRM esta ativo e os
modulos `Companies`, `Clients`, `Contracts`, `People` e `Network` possuem
features dedicadas.

O front possui camada HTTP propria e consome endpoints reais do backend para os
modulos operacionais. Dados mock/sample nao entram mais no runtime real nem no
bundle publicado. O `dev-token` fica limitado a localhost/loopback com opt-in
explicito; host publico exige Firebase real e Firebase Admin no backend.

## Documentacao Viva

- [Indice documental](docs/README.md)
- [Guia operacional, seguranca e deploy](docs/guia-operacional-ambientes-e-funcoes.md)
- [Estado atual e proximos passos](docs/current-implementation-status.md)
- [Consolidacao arquitetural do front](docs/front-architecture-consolidation.md)
- [Contrato relacional de Network](docs/relational-graph-contract.md)
- [Design system CRM](docs/new-ui-design-system.md)
- [Icones e moldes](docs/icones-moldes.md)

## Regras de Integracao

- Toda relacao usa `publicId`, nunca ID interno.
- A API fica em `/api/v1`.
- Em build web no mesmo host do Apache, o front usa `/api/v1` automaticamente.
- Se a API ficar em outro host, buildar com
  `--dart-define=PARIFLOW_API_BASE_URL=https://dominio/api/v1`.
- Para desenvolvimento online, use:
  - `scripts/run-web-online.ps1` para Web;
  - `scripts/run-android-online.ps1` para Android;
  - `scripts/build-web-production.ps1` para build de producao.
- Em `flutter run`, o padrão de debug aponta para a API online; para backend
  local, passe explicitamente `--dart-define=PARIFLOW_API_BASE_URL=http://localhost:3000/api/v1`.
- Em `localhost` ou `127.0.0.1`, o app mostra um aviso fixo de preview local no
  canto superior direito. Esse aviso nao aparece em deploy publico.
- Conteudo sensivel, anexos e permissao seguem ACL do backend; o front nao
  infere acesso nem exibe metadado protegido sem autorizacao.
- Quando a API falha ou retorna vazia, a tela deve mostrar estado empty/error
  sem preencher com mock silencioso.
