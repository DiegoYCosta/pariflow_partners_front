# Busca Global - Especificacao Front

Data de referencia: `2026-07-12`.

Status: implementado em `2026-07-13`. Depende de `GET /api/v1/search`.

## Objetivo

Transformar o campo visual do header em busca funcional com teclado, grupos de
resultado, ACL e navegacao direta.

## Comportamento

- abrir popover ao focar ou digitar;
- buscar apos 2 caracteres com debounce;
- agrupar por tipo;
- navegar com setas, Enter e Esc;
- abrir origem canonica por `routeTarget`;
- preservar tenant vindo da sessao, sem query local;
- mostrar vazio autorizado quando nao houver resultado.

## Estados

- inicial;
- carregando;
- resultado;
- vazio;
- erro;
- sem sessao.

## Nao fazer

- buscar localmente em payloads ja carregados como fonte primaria;
- retornar notas privadas na primeira fase;
- mostrar historico recente antes de regra de privacidade;
- mostrar contagem de bloqueados.

## Criterio de aceite

- pessoa conhecida abre em ate 10 segundos;
- resultado abre workspace correto;
- teclado funciona sem mouse;
- falha de API mostra erro sem mock.

## Estado implementado

- Header CRM consulta `/api/v1/search` apos 2 caracteres com debounce.
- Resultados aparecem em popover agrupado por tipo.
- Setas, Enter e Esc controlam a lista sem mouse.
- Resultado abre o workspace canonico e seleciona o `publicId` retornado pela
  API quando a tela carrega seus dados.
- Falha de API mostra erro e acao de tentar novamente, sem fallback local/mock.
