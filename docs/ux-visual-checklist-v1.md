# Checklist Visual UX v1

Data de referencia: `2026-07-12`.

Status: checklist antes de implementar/refinar telas.

## Global

- Shell CRM preservado.
- Sem navegacao paralela.
- Um titulo principal por workspace.
- Uma acao primaria por contexto.
- Acoes secundarias agrupadas.
- Sem card dentro de card.
- Estados loading, vazio, erro e sem permissao.
- Conteudo sensivel sem titulo/resumo/contagem quando bloqueado.
- Foco visivel em controles.
- Texto cabe em botoes e paineis.

## Home

- Ate cinco prioridades visiveis.
- Agenda imediata compacta.
- Prazos acionaveis.
- Itens para retomar autorizados.
- Graficos removidos ou subordinados a acao.
- Empty state compacto.

## Pessoas

- Lista com filtros rapidos.
- Desligados diferenciados sem depender so de cor.
- Cabecalho de ficha com status e vinculo atual.
- Abas claras.
- Historico formal separado de notas informais.
- Acoes principais visiveis.

## Timeline

- Modos Calendario, Agenda e Diario distinguiveis.
- Passado/futuro por posicao, rotulo e icone.
- Filtros avancados recolhidos.
- Detalhe em gaveta quando possivel.
- Origem do registro visivel.

## Focus Board

- Estado vazio nao domina a tela.
- Recolhido/acoplado/destacado coerentes.
- Nota privada/compartilhada rotulada.
- API error nao parece empty state.
- Local legado rotulado como local.
- Migracao manual clara.

## Responsividade

- Desktop priorizado.
- Focus Board nao comprime workspace abaixo de largura operacional.
- Tabelas/listas mantem leitura.
- Botoes nao quebram texto.
- Header nao sobrepoe busca, relatorios e perfil.

## Validacao visual

- screenshot desktop;
- screenshot largura media;
- screenshot mobile/tablet quando aplicavel;
- dados vazios;
- dados volumosos;
- erro de API;
- sem permissao.
