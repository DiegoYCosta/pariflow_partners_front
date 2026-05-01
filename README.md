# PariFlow Partners Front

Frontend Flutter do PariFlow Partners com alvo em Web e Android.

O projeto ainda esta na fase de fundacao tecnica. A fonte de verdade para planejamento, arquitetura e integracao do front fica em [docs/README.md](docs/README.md).

## Documentacao

- [Visao geral e ordem de leitura](docs/README.md)
- [Planejamento funcional do front](docs/front-planning.md)
- [Conceito de layout inicial](docs/front-layout-concept.md)
- [Arquitetura Flutter](docs/front-architecture.md)
- [Integracao com backend](docs/front-backend-integration.md)
- [Roadmap de implementacao](docs/front-implementation-roadmap.md)

## Contexto atual

- o backend ja expoe contratos iniciais em `/api/v1` e Swagger em `/api/docs`;
- o dominio do produto esta documentado em `../DPPRO_JOTABE/Documentacao`;
- o codigo atual do front ja saiu do monolito em `main.dart`, foi separado fisicamente por `app`, `core`, `shared` e `features`, e ainda funciona como prototipo visual sem integracao real com backend;
- empresas, contratos, pessoas e teia ja possuem pastas e fixtures proprias;
- o prototipo tambem documenta tags sensiveis operacionais para empresa e colaborador, com envio sem login e consulta autenticada.
