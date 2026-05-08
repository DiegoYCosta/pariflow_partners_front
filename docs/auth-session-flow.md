# Fluxo de Autenticacao e Sessao

Data de referencia: `2026-05-07`.

## Fluxo Principal

1. O Flutter inicializa Firebase Web quando as `dart-define` publicas estiverem
   presentes.
2. O usuario autentica por e-mail/senha no Firebase.
3. O front obtem o Firebase ID Token do usuario autenticado.
4. O front envia esse token para `POST /api/v1/auth/session/exchange`.
5. O backend valida o token com Firebase Admin e emite a sessao interna/JWT.
6. As proximas chamadas usam `Authorization: Bearer <accessToken>`.

## Regra do Dev Token

`PARIFLOW_ENABLE_DEV_TOKEN` e desligado por padrao. Se o define nao for
informado, o front nao envia `dev-token`.

Em host publico, o front nunca envia `dev-token`, mesmo se alguem buildar com:

```powershell
flutter build web --release --dart-define=PARIFLOW_ENABLE_DEV_TOKEN=true
```

Uso permitido somente em ambiente local explicito. Primeiro suba o backend no
modo local controlado:

```powershell
cd "D:\DEV\flutter\JOTABE\PariFlow Partners - Back"
npm.cmd run dev:local-token
```

Esse comando prende o back em loopback, usa o MySQL local isolado do projeto em
`127.0.0.1:3308`, aplica migrations e habilita `DEV_AUTH_BYPASS=true` somente
nesse processo.

Depois suba o front apontando para a API local:

```powershell
cd "D:\DEV\flutter\JOTABE\PariFlow Partners - Front"
.\scripts\run-web-local.ps1 -UseDevToken
```

Esse modo so deve apontar para API local/controlada. Para API online, use login
Firebase real; os scripts `run-web-online.ps1` e `run-mobile-online.ps1`
desligam `dev-token` por padrao, e o web online recusa `-UseDevToken` quando o
destino nao e localhost.

Build release deve depender de Firebase real:

```powershell
flutter build web --release --dart-define=PARIFLOW_ENABLE_DEV_TOKEN=false
```

## Responsabilidades

| Parte | Responsabilidade |
| --- | --- |
| Flutter | login Firebase, envio do token e uso do access token interno |
| Firebase Client SDK | autenticar usuario e emitir Firebase ID Token |
| Backend | validar Firebase ID Token e emitir JWT/sessao interna |
| Firebase Admin | validar assinatura e usuario real no backend |

## Producao

Antes de publicar como producao:

1. habilitar Email/Password no Firebase;
2. criar usuarios reais;
3. configurar Firebase Admin no backend;
4. desligar `PREVIEW_AUTH_BYPASS` e `DEV_AUTH_BYPASS`;
5. manter build release sem `dev-token`.
