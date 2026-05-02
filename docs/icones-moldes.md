# Colinha de Moldes dos Icones

Base de referencia: `assets/images/Icones.webp`

## Objetivo

Definir uma nomenclatura unica para o sprite de icones, sem precisar gerar novas imagens.

Cada icone passa a existir como um `molde` logico com dois estados:

- `base`: versao clara/prateada
- `selected`: versao dourada

Regra fixa:

- dourado e exclusivo para funcao selecionada/ativa
- a imagem fonte continua sendo uma so: `Icones.webp`
- o sistema deve recortar/chamar o molde certo, nao duplicar assets

## Contrato de chamada

Formato canonico:

```text
mold.<nome>.<estado>
```

Exemplos:

```text
mold.home.base
mold.home.selected
mold.network.base
mold.network.selected
```

## Mapa dos moldes

## Linha 1

| Molde | Nome canonico | Leitura visual | Uso principal | Estado dourado |
| --- | --- | --- | --- | --- |
| `mold.home` | `home` | casa | inicio, dashboard, tela principal | home selecionada |
| `mold.company` | `company` | predio/empresa | companies, cliente, estrutura empresarial | modulo empresarial selecionado |
| `mold.document` | `document` | documento | contratos, registros, anexos, dossie | modulo documental selecionado |

## Linha 2

| Molde | Nome canonico | Leitura visual | Uso principal | Estado dourado |
| --- | --- | --- | --- | --- |
| `mold.people` | `people` | grupo de pessoas | people, colaboradores, usuarios | modulo de pessoas selecionado |
| `mold.network` | `network` | conexoes em rede | network, relationship map, oportunidades relacionais | modulo relacional selecionado |
| `mold.analytics` | `analytics` | grafico | reports, metricas, analytics, painel executivo | modulo analitico selecionado |

## Linha 3

| Molde | Nome canonico | Leitura visual | Uso principal | Estado dourado |
| --- | --- | --- | --- | --- |
| `mold.calendar` | `calendar` | calendario | agenda, prazos, timeline, eventos | funcao de agenda selecionada |
| `mold.notification` | `notification` | sino | alertas, notificacoes, lembretes | notificacoes abertas/ativas |
| `mold.security` | `security` | escudo | compliance, seguranca, validacao, aprovacao | area de seguranca selecionada |

## Linha 4

| Molde | Nome canonico | Leitura visual | Uso principal | Estado dourado |
| --- | --- | --- | --- | --- |
| `mold.settings` | `settings` | engrenagem | admin, configuracoes, parametros | area administrativa selecionada |

## Regra de estados

| Estado | Nome | Uso |
| --- | --- | --- |
| `base` | prateado/claro | item inativo, disponivel, nao selecionado |
| `selected` | dourado | item selecionado, funcao ativa, modulo atual |

## Regra semantica

- `company` cobre empresa, companhia, cliente empresarial ou estrutura corporativa
- `document` cobre contrato, documento, anexo, registro ou dossie
- `network` cobre rede relacional, conexoes, malha ou leitura de oportunidades
- `analytics` cobre relatorios, metricas, dashboards e visao gerencial
- `security` cobre seguranca, compliance, acesso sensivel e aprovacoes
- `settings` cobre administracao, configuracoes e parametros

## Ordem visual do sprite

Leitura do `Icones.webp`:

```text
linha 1: home | company | document
linha 2: people | network | analytics
linha 3: calendar | notification | security
linha 4: settings
```

Dentro de cada par:

```text
esquerda = base
direita = selected
```

## Pedido padrao quando quiser usar um icone

Se voce quiser me pedir depois, o formato ideal fica assim:

```text
usar mold.home.base
usar mold.company.selected
usar mold.network.selected
trocar o card de relatorios para mold.analytics.base
```

## Mapa rapido por modulo do projeto

| Modulo/tela | Molde sugerido |
| --- | --- |
| Home | `mold.home` |
| Companies | `mold.company` |
| Client Companies | `mold.company` |
| Contracts | `mold.document` |
| People | `mold.people` |
| Network | `mold.network` |
| Reports | `mold.analytics` |
| Agenda / Timeline | `mold.calendar` |
| Notifications | `mold.notification` |
| Security / Compliance | `mold.security` |
| Admin / Settings | `mold.settings` |

## Regra para nao criar novos arquivos

Sempre usar:

- asset fonte unico: `assets/images/Icones.webp`
- nome logico do molde: `mold.<nome>`
- variacao visual: `.base` ou `.selected`

Nao criar:

- `home_gold.webp`
- `home_white.webp`
- `network_selected.webp`
- duplicacoes por tela ou modulo

## Versao curta

```text
home
company
document
people
network
analytics
calendar
notification
security
settings
```

Com estados:

```text
base
selected
```
