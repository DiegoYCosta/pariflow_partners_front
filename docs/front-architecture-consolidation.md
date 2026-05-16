# Consolidacao Arquitetural do Front

Data de referencia: `2026-05-14`.

## Objetivo

Reduzir acoplamento sem redesenhar a aplicacao. O front ainda usa `part` em
varias areas, mas os pontos sensiveis ja foram isolados ou removidos do runtime
real.

## Estado atual

- `lib/core/api/api_client.dart` esta fora de `part` e centraliza HTTP,
  envelope, sessao, refresh e logout.
- `lib/features/auth/auth_gate.dart` esta importavel e concentra Firebase,
  login, onboarding publico e seletor de empresa raiz pos-login.
- `lib/firebase_options.dart` usa `String.fromEnvironment` para Firebase Web.
- Mocks/sample data foram removidos de `lib/` como fallback de runtime.
- Network consome `GET /api/v1/network/graph`.
- Home consome `GET /api/v1/dashboard/home`.
- Timeline consome `timeline`, `agenda` e `agenda/non-business-days`.
- Reports consome `POST /api/v1/relatorios/executar`.
- Companies, Clients, Contracts e People usam repositorios de API e estados
  empty/error sem fallback mock.
- Identidade visual ja possui modelos publicos, gerador, componentes e cache
  local por `shared_preferences`.

## Fronteiras esperadas

| Camada | Responsabilidade |
| --- | --- |
| Presentation | telas, widgets, paineis, formularios e interacao |
| Domain | modelos principais e transformacoes puras |
| Data / Infrastructure | API, Firebase, HTTP, storage local e adapters externos |

## Proximos cortes seguros

1. Separar `entity_workspace_api_data.dart` em adapter importavel.
2. Separar `people_api_data.dart` em adapter importavel.
3. Extrair API da Timeline para adapter importavel.
4. Reduzir `part` em `app.dart`, feature por feature.
5. Persistir identidade visual no backend antes de expandir customizacao.
6. Manter `dart analyze`, `flutter test` e build web passando a cada corte.

## Criterios

- Repositorios/adapters nao devem depender de widgets.
- Arquivos de dominio nao devem importar Flutter UI quando desnecessario.
- Nenhuma extracao pode reintroduzir mocks no runtime real.
- Host publico continua sem `dev-token`.
- O front nao deve aceitar tenant vindo de rota, query ou storage local como
  autoridade; contexto de empresa precisa vir de sessao assinada pelo backend.
