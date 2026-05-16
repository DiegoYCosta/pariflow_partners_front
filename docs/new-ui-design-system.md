# Design System CRM

Data de referencia: `2026-05-14`.

## Objetivo

Manter a identidade visual atual enquanto os modulos operacionais entram em uso
real. O proximo passo nao e redesenhar tudo; e estabilizar densidade, estados,
responsividade e componentes compartilhados.

## Tokens atuais

| Token | Uso |
| --- | --- |
| `_canvasColor` | fundo geral |
| `_paperColor` | superficies e paineis |
| `_lineColor` | bordas discretas |
| `_inkColor` | texto principal |
| `_mutedColor` | texto secundario |
| `_tealColor` | sucesso/ativo/contexto primario |
| `_amberColor` | atencao/historico |
| `_roseColor` | risco/encerrado |
| `_slateColor` | neutro/apoio |

## Componentes base

- shell CRM;
- `_EntityWorkspace`;
- paineis mestre-detalhe;
- tags de status;
- painel de acoes CRUD;
- Focus Board persistente;
- Timeline/calendario;
- Network em lanes;
- Central de Relatorios;
- gates de sensivel/anexos;
- `EntityMarker`, `EntityBadge`, `EntityChip` e picker de identidade visual.

## Regras

- Nao criar layout paralelo para modulo que ja cabe no shell.
- Nao colocar cards dentro de cards.
- Usar densidade de ferramenta operacional, nao landing page.
- Todo estado real precisa ter loading, empty e error.
- Fallback com mock nao pode aparecer em execucao real.
- Conteudo sensivel nao pode vazar quantidade, titulo ou resumo.
- Botoes de CRUD devem preservar historico e preferir inativacao/cancelamento
  quando houver relacao operacional.
- Formas e cores de identidade visual nao substituem textos/acessibilidade.

## Pendente

- Validar breakpoints Web/Android/iOS.
- Revisar textos longos em botoes e cards.
- Padronizar estados de erro por modulo.
- Persistir identidade visual no backend.
- Revisar Network e Timeline com dados volumosos reais.
