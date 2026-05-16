# Guia Operacional, Seguranca e Deploy

Data de referencia: `2026-05-14`.

Runbook consolidado do front para ambientes, autenticacao, integracao com
backend e deploy AWS.

## Ambientes

| Ambiente | Uso | Base |
| --- | --- | --- |
| Front local | Desenvolvimento Flutter Web | `http://127.0.0.1:8082` pelos scripts |
| Back local | API NestJS/Prisma | `http://localhost:3000/api/v1` |
| Proxy online local | Flutter debug contra AWS | `http://127.0.0.1:3002/api/v1` |
| AWS homologacao | Validacao tecnica | `https://pariflowpartners.com.br/` apos DNS/HTTPS |
| Producao | Uso real | `https://pariflowpartners.com.br/` |

No AWS atual, Apache serve o Flutter em `/` e encaminha `/api` e `/health` para
o backend em `127.0.0.1:3001`. O dominio so deve entrar em uso depois que o
DNS resolver para o IP publico fixo da EC2 e o HTTPS estiver emitido.

## Regras de autenticacao

- Host publico nunca deve aceitar `dev-token`.
- `dev-token` so funciona em localhost/loopback com opt-in explicito.
- AWS/producao exige Firebase Web no front e Firebase Admin no backend.
- Firebase Admin fica somente no backend.
- Swagger fica desligado em producao/homologacao publica.

Fluxo real:

1. Usuario autentica por Email/Password no Firebase.
2. Front obtem Firebase ID Token.
3. Front chama `POST /api/v1/auth/session/exchange`.
4. Back valida com Firebase Admin, emite access token interno e refresh cookie.
5. Front mostra a tela de contexto empresarial.
6. Usuario escolhe uma empresa raiz aprovada ou solicita novo vinculo.
7. Para entrar, o front chama `POST /api/v1/auth/company-context`; o backend
   valida `usuario_empresa_raiz_acesso` e emite sessao escopada.
8. Front usa Bearer interno nas rotas protegidas.
9. `ApiClient` tenta `auth/refresh` quando recebe `401`.
10. Logout chama `auth/logout`, limpa sessao local e desloga Firebase quando aplicavel.

## Comandos locais

Back local com token de dev:

```powershell
cd "D:\DEV\flutter\JOTABE\PariFlow Partners - Back"
npm.cmd run dev:local-token
```

Front local contra back local:

```powershell
cd "D:\DEV\flutter\JOTABE\PariFlow Partners - Front"
.\scripts\run-web-local.ps1 -UseDevToken
```

Front local contra AWS por proxy:

```powershell
.\scripts\run-web-online.ps1
```

Build web release:

```powershell
.\scripts\build-web-production.ps1
```

Android online:

```powershell
.\scripts\run-android-online.ps1
```

## Variaveis do front

Arquivo exemplo: `.env.front.example`.

- `PARIFLOW_FIREBASE_API_KEY`
- `PARIFLOW_FIREBASE_AUTH_DOMAIN`
- `PARIFLOW_FIREBASE_PROJECT_ID`
- `PARIFLOW_FIREBASE_STORAGE_BUCKET`
- `PARIFLOW_FIREBASE_MESSAGING_SENDER_ID`
- `PARIFLOW_FIREBASE_APP_ID`
- `PARIFLOW_FIREBASE_MEASUREMENT_ID`
- `PARIFLOW_ENABLE_DEV_TOKEN`
- `PARIFLOW_API_BASE_URL`

Scripts ignoram `PARIFLOW_API_BASE_URL` e `PARIFLOW_ENABLE_DEV_TOKEN` do env
quando precisam forcar valores seguros.

## Deploy AWS

Script principal:

```powershell
& "D:\DEV\flutter\JOTABE\deploy_pfp_aws.ps1" -SkipSeed
```

O deploy deve:

- buildar front com `PARIFLOW_ENABLE_DEV_TOKEN=false`;
- publicar Flutter Web no Apache;
- publicar back NestJS/Prisma via PM2;
- preservar `.env` remoto quando existir;
- manter bypass, seed sample, Swagger e submissions publicas desligados;
- manter `COOKIE_SECURE=true` no `.env` remoto;
- rodar Prisma generate/migrate;
- validar `/health/live`.

## Smoke manual

```powershell
$base = "https://pariflowpartners.com.br"
Invoke-WebRequest "$base/health/live" -UseBasicParsing
Invoke-WebRequest "$base/api/v1/empresas-prestadoras" -UseBasicParsing
```

Rota protegida sem token deve retornar `401`. `GET /api/docs` deve retornar
`404` em host publico.

## Guardrails

Front:

```powershell
dart analyze
flutter test --reporter=compact
flutter build web --release --dart-define=PARIFLOW_ENABLE_DEV_TOKEN=false
```

Back:

```powershell
npm.cmd run lint
npm.cmd run build
npm.cmd audit --omit=dev --omit=optional
```

## Pendencias reais

1. Finalizar DNS/HTTPS na AWS e validar o dominio publico.
2. Usuarios reais, perfis internos e smoke de login online.
3. Backup/restore de banco.
4. Exportacao e jobs de relatorios.

## Riscos de seguranca a validar

- Confirmar que editar URL, storage local ou cookie nao altera empresa ativa;
  somente `auth/company-context` deve emitir token com tenant.
- Confirmar que usuario sem vinculo aprovado so acessa solicitacoes proprias.
- Confirmar que usuario com duas empresas ve apenas dados da empresa ativa.
- Confirmar refresh token em HTTPS preserva a empresa escolhida.
- Confirmar logout revoga refresh token e limpa Firebase/local session.
