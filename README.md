# PariFlow Partners Front

Frontend Flutter do PariFlow Partners com alvo Web, Android e iOS.

Data de referencia: `2026-05-14`.

## Estado atual

O projeto ja nao esta em fundacao conceitual. O shell CRM esta ativo e os
modulos `Home`, `Companies`, `Clients`, `Contracts`, `People`, `Network` e
`Timeline` possuem features dedicadas. A Central de Relatorios fica no topo do
shell como fluxo transversal.

O front possui camada HTTP propria, Firebase Web, controle de sessao interna,
refresh/logout, estados loading/empty/error e consumo real dos endpoints do
backend. Dados mock/sample nao entram no runtime real nem no bundle publicado.

## Modulos e integracoes

| Area | Estado |
| --- | --- |
| Auth | Firebase Web, `session/exchange`, refresh automatico, logout e tela publica de cadastro de cliente |
| Home | dashboard real via `GET /api/v1/dashboard/home` |
| Companies | lista, detalhe e CRUD via `empresas-prestadoras` |
| Clients | lista, detalhe e CRUD via `clientes` |
| Contracts | contratos, tipos, modelos, servicos, postos e documentos |
| People | pessoa, vinculos, ocorrencias, anexos, agenda e Focus Board |
| Focus Board | hub persistente acoplado/desacoplado com dados da API |
| Timeline | calendario mensal operacional com timeline, agenda e dias nao uteis |
| Reports | catalogo e execucao real via `POST /api/v1/relatorios/executar` |
| Network | grafo real via `GET /api/v1/network/graph` |
| Perfil/configuracoes | `GET/PATCH /auth/me`, calendario, contatos e onboarding interno |
| Identidade visual | marcadores, badges, chips, picker e cache local por `shared_preferences` |

## Documentacao viva

- [Indice documental](docs/README.md)
- [Estado atual e proximos passos](docs/current-implementation-status.md)
- [Guia operacional, seguranca e deploy](docs/guia-operacional-ambientes-e-funcoes.md)
- [Consolidacao arquitetural do front](docs/front-architecture-consolidation.md)
- [Calendario, Timeline e relatorios](docs/calendario-compartilhado-e-relatorios.md)
- [Contrato relacional de Network](docs/relational-graph-contract.md)
- [Design system CRM](docs/new-ui-design-system.md)
- [Sistema visual de cores e formas](docs/sistema-visual-de-cores-e-formas.md)
- [Icones e moldes](docs/icones-moldes.md)

As pastas externas `D:\DEV\flutter\JOTABE\docs - FRONT` e
`D:\DEV\flutter\JOTABE\DPPRO_JOTABE\Documentacao` continuam como referencia,
mas os documentos operacionais tambem estao em `PariFlow Partners - Front/docs`.

## Ambiente e autenticacao

- A API fica em `/api/v1`.
- Em build web release no mesmo host do Apache, o front usa `/api/v1` por
  padrao quando `PARIFLOW_API_BASE_URL` nao for informado.
- Em debug web sem `dart-define`, o default aponta para
  `http://127.0.0.1:3002/api/v1`, usado pelo proxy local do script online.
- Para backend local, use:

```powershell
.\scripts\run-web-local.ps1 -UseDevToken
```

- Para API online via proxy local:

```powershell
.\scripts\run-web-online.ps1
```

- Para build web de producao:

```powershell
.\scripts\build-web-production.ps1
```

- Para Android online:

```powershell
.\scripts\run-android-online.ps1
```

`dev-token` so funciona em localhost/loopback com opt-in explicito. Host
publico exige Firebase real e Firebase Admin no backend.

## Regras de integracao

- Toda relacao usa `publicId`, nunca ID interno.
- O front espera envelope `{ data, meta }` em sucesso e `{ error }` em erro.
- Conteudo sensivel, anexos, tags e permissoes seguem ACL do backend.
- Quando a API falha ou retorna vazia, a tela mostra empty/error sem preencher
  mock silencioso.
- Firebase Web usa somente variaveis `PARIFLOW_FIREBASE_*`.
- Service Account Firebase, JWT secrets, SMTP, WhatsApp, banco e AWS ficam
  somente no backend/infra.

## Validacao local

```powershell
cd "D:\DEV\flutter\JOTABE\PariFlow Partners - Front"
flutter pub get
dart analyze
flutter test --reporter=compact
flutter build web --release --dart-define=PARIFLOW_ENABLE_DEV_TOKEN=false
```

## Pendencias reais

1. Configurar dominio e HTTPS.
2. Criar usuarios reais, conceder perfis internos e validar login online.
3. Fechar UX completa de refresh/logout e sessao longa.
4. Persistir identidade visual no backend, substituindo cache local por dispositivo.
5. Evoluir calendario/comunicados com preview de audiencia e ciencia.
6. Evoluir relatorios com exportacao, modelos persistidos e auditoria final.
7. Validar responsividade Web/Android/iOS com dados reais.
