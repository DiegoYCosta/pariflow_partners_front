# Sistema Visual de Cores e Formas

Data de referencia: `2026-05-13`.

## Objetivo

Definir um sistema visual para identificar, de forma consistente, o tipo e a
identidade de entidades que aparecem em contextos mistos do produto, como
tarefas, chats, notificacoes, linhas do tempo, calendarios, kanban, Network e
paineis operacionais.

O sistema deve ajudar a pessoa usuaria a reconhecer rapidamente se uma
informacao esta relacionada a uma empresa, cliente, contrato, posicao,
categoria, grupo ou outro objeto de negocio, sem depender exclusivamente do
texto.

A regra central e:

| Elemento visual | Responsabilidade |
| --- | --- |
| Forma geometrica | Identificar o tipo da entidade |
| Cor, gradiente ou padrao | Identificar a entidade especifica |
| Texto curto | Confirmar o nome e reduzir ambiguidades |
| Tooltip ou detalhe expandido | Expor informacao completa quando necessario |

## Principios

- A forma comunica o tipo da entidade antes da cor.
- A cor ou padrao identifica uma entidade especifica dentro do projeto.
- A identidade visual deve ser estavel depois da criacao da entidade.
- A pessoa que cadastra ou edita uma entidade pode ajustar a identidade visual.
- O sistema deve evitar repeticao visual dentro do mesmo projeto sempre que
  possivel.
- A interface nunca deve depender apenas de cor para comunicar significado.
- Cores reservadas para estado operacional, como erro, atraso, sucesso e
  atencao, devem ser usadas com cuidado para nao competir com identidade.
- A renderizacao deve ser centralizada em componentes reutilizaveis, evitando
  implementacoes diferentes em cada tela.

## Escopo

Este documento cobre:

- linguagem visual por tipo de entidade;
- diferenca entre origem e vinculos;
- regras de geracao automatica;
- edicao manual da identidade visual;
- modelo conceitual de dados;
- componentes de interface;
- comportamento em tarefas, chats e listas;
- plano de implementacao.

Este documento nao define:

- redesign completo do CRM;
- mudanca de navegacao principal;
- alteracao das regras de negocio de contratos, clientes ou empresas;
- substituicao dos tokens do design system existente.

## Conceitos

### Entidade

Objeto de negocio que pode aparecer em telas operacionais. Exemplos:

- empresa;
- cliente;
- contrato;
- posicao;
- categoria;
- grupo ou equipe;
- usuario, quando aplicavel.

### Identidade visual

Conjunto de atributos graficos usados para representar uma entidade.

Exemplo:

```txt
Empresa Pariflow
- tipo: empresa
- forma: hexagono
- cor principal: azul petroleo
- padrao: solido
```

### Origem

Entidade ou contexto a partir do qual uma acao foi criada.

Exemplo:

```txt
Uma tarefa criada dentro do detalhe de uma empresa tem origem na empresa.
```

### Vinculo

Entidade relacionada a uma acao, sem necessariamente ser o ponto de origem.

Exemplo:

```txt
Uma tarefa pode ter origem em um grupo e, ao mesmo tempo, estar vinculada a um
cliente, uma empresa, um contrato e uma categoria.
```

## Matriz Visual por Tipo de Entidade

| Tipo | Forma | Tratamento visual | Uso principal |
| --- | --- | --- | --- |
| Empresa | Hexagono | Cores frias e escuras | Organizacoes, prestadoras, parceiros |
| Cliente | Pentagono | Cores quentes | Pessoas ou clientes operacionais |
| Contrato | Losango achatado | Cor fria com pontilhado cinza-claro | Acordos, vinculos formais, documentos |
| Posicao | Quadrado | Gradiente de frio escuro para quente | Cargos, vagas, funcoes, posicoes |
| Categoria | Circulo | Padrao organico com pelo menos 3 cores | Classificacoes e temas operacionais |
| Grupo ou equipe | Triangulo ou escudo | Base neutra com acento colorido | Grupos de trabalho, times, comunidades |

## Regras por Tipo

### Empresas

Empresas devem ser tratadas com uma linguagem mais institucional e estavel.

Definicao:

- forma: hexagono;
- familia de cores: frias e escuras;
- padrao inicial: solido;
- uso recomendado: empresas prestadoras, empresas parceiras, unidades
  corporativas e organizacoes.

Paleta inicial sugerida:

| Ordem | Nome operacional | Exemplo aproximado |
| --- | --- | --- |
| 1 | Azul petroleo | `#0F4C5C` |
| 2 | Azul marinho | `#12355B` |
| 3 | Verde pinho | `#1F4D3A` |
| 4 | Verde oliva escuro | `#3F4A2F` |
| 5 | Grafite azulado | `#2F3E46` |
| 6 | Roxo profundo | `#352B5B` |
| 7 | Ciano escuro | `#155E63` |

Regra de selecao:

1. Ao criar uma empresa, o sistema seleciona uma cor fria e escura ainda nao
   usada no projeto.
2. As primeiras 7 empresas usam a paleta inicial, quando disponivel.
3. Se as 7 cores forem usadas, o sistema libera um novo grupo de 7 variacoes.
4. Novos grupos devem preservar a leitura fria e escura, sem se aproximar das
   cores de status critico.
5. A pessoa usuaria pode trocar a cor durante o cadastro ou edicao.

### Clientes

Clientes devem ter leitura mais humana e direta, com uma familia visual
distinta das empresas.

Definicao:

- forma: pentagono;
- familia de cores: quentes;
- padrao inicial: solido;
- uso recomendado: clientes, contatos principais e pessoas externas tratadas
  como cliente.

Paleta inicial sugerida:

| Ordem | Nome operacional | Exemplo aproximado |
| --- | --- | --- |
| 1 | Coral fechado | `#C75C48` |
| 2 | Terracota | `#B65A3C` |
| 3 | Ambar escuro | `#B7791F` |
| 4 | Laranja queimado | `#B85C24` |
| 5 | Rosa antigo | `#B5546A` |
| 6 | Vermelho queimado | `#A94438` |
| 7 | Dourado profundo | `#9F741A` |

Regra de selecao:

1. Ao criar um cliente, o sistema seleciona uma cor quente ainda nao usada no
   projeto.
2. A selecao pode ser aleatoria, desde que respeite a regra de nao repeticao
   enquanto houver opcoes disponiveis.
3. A cor deve poder ser alterada no cadastro ou edicao.
4. A forma pentagonal permanece fixa para clientes.

### Contratos

Contratos devem ter uma leitura documental e formal, diferente de empresas e
clientes.

Definicao:

- forma: losango achatado;
- familia de cores: frias;
- padrao: pontilhado em cinza-claro;
- proporcao: mais baixa que os demais simbolos, mantendo largura semelhante;
- uso recomendado: contratos, aditivos, modelos contratuais e documentos
  formais, quando forem tratados como entidades de contexto.

Regra de renderizacao:

1. O losango deve ter altura menor que o marcador padrao.
2. A largura deve permanecer compativel com os demais marcadores.
3. O pontilhado deve ser visivel em tamanhos pequenos.
4. O pontilhado deve usar cinza-claro ou tom neutro equivalente, mantendo
   contraste suficiente no tema claro e escuro.
5. A cor base identifica o contrato especifico.

Exemplo conceitual:

```txt
Contrato de Implantacao 2026
- forma: losango achatado
- cor base: azul frio
- padrao: pontos cinza-claro
```

### Posicoes

Posicoes representam cargos, funcoes, vagas ou papeis estruturados.

Definicao:

- forma: quadrado;
- familia de cores: gradiente;
- gradiente: de cor fria e escura para cor quente;
- uso recomendado: cargos, funcoes, postos, vagas e posicoes operacionais.

Regra de selecao:

1. Cada posicao recebe um gradiente proprio.
2. O inicio do gradiente deve usar uma cor fria e escura.
3. O final do gradiente deve usar uma cor quente.
4. O quadrado permanece fixo para posicoes.
5. O gradiente deve ser discreto o suficiente para nao parecer estado de
   progresso ou alerta.

### Categorias

Categorias devem funcionar como classificadores visuais, sem competir com as
entidades principais.

Definicao:

- forma: circulo;
- tratamento visual: padrao organico;
- composicao: pelo menos 3 cores distintas;
- uso recomendado: categorias, temas, agrupadores e classificacoes.

Regra de geracao:

1. Cada categoria recebe um circulo com padrao proprio.
2. O padrao deve usar pelo menos 3 cores distintas.
3. As manchas ou formas organicas devem ser controladas, evitando excesso de
   ruido em tamanhos pequenos.
4. Padroes aceitos: manchas suaves, ondas, mosaico leve, pontos organicos ou
   listras organicas.
5. A categoria deve continuar reconhecivel em marcadores pequenos, chips e
   listas densas.

### Grupos ou Equipes

Grupos ou equipes precisam de tratamento proprio caso sejam usados como origem
de tarefas, participantes de chat ou contexto de colaboracao.

Definicao sugerida:

- forma: triangulo ou escudo;
- familia de cores: neutra com acento colorido;
- uso recomendado: grupos de trabalho, equipes, comunidades, filas
  compartilhadas e contextos colaborativos.

A escolha entre triangulo e escudo deve considerar o uso real:

| Forma | Quando usar |
| --- | --- |
| Triangulo | Para grupos simples, filtros e agrupamentos leves |
| Escudo | Para equipes com permissao, responsabilidade ou papel institucional |

## Origem e Vinculos

A origem e os vinculos devem ser tratados como conceitos separados.

Uma tarefa pode nascer em uma empresa, mas envolver um cliente e um contrato.
Tambem pode nascer em um grupo e estar vinculada a diversas entidades.

### Origem principal

A origem principal representa o contexto de criacao.

Exemplos:

```txt
Tarefa criada no detalhe da empresa:
- origem_tipo: empresa
- origem_id: empresa.id
```

```txt
Tarefa criada no chat de um grupo:
- origem_tipo: grupo
- origem_id: grupo.id
```

```txt
Tarefa criada diretamente no quadro geral:
- origem_tipo: manual
- origem_id: null
```

### Vinculos secundarios

Vinculos secundarios representam entidades relacionadas.

Exemplo:

```txt
Tarefa: Revisar documento de implantacao
- origem: grupo Comercial
- vinculos:
  - empresa Pariflow
  - cliente Joao Silva
  - contrato Implantacao 2026
  - categoria Documentos
```

Regra de interface:

- a origem deve aparecer em posicao principal;
- os vinculos devem aparecer como chips secundarios;
- quando houver pouco espaco, a origem permanece visivel e os vinculos podem
  ser recolhidos;
- o detalhe expandido deve listar todos os vinculos.

## Modelo Conceitual de Dados

### Identidade visual

Modelo sugerido:

```ts
type EntityType =
  | 'company'
  | 'client'
  | 'contract'
  | 'position'
  | 'category'
  | 'group'
  | 'user';

type VisualShape =
  | 'hexagon'
  | 'pentagon'
  | 'flatDiamond'
  | 'square'
  | 'circle'
  | 'triangle'
  | 'shield';

type VisualPattern =
  | 'solid'
  | 'dots'
  | 'gradient'
  | 'organicBlobs'
  | 'waves'
  | 'mosaic';

type VisualIdentity = {
  id: string;
  projectId: string;
  entityType: EntityType;
  entityId: string;
  shape: VisualShape;
  primaryColor: string;
  secondaryColors?: string[];
  pattern: VisualPattern;
  variantIndex: number;
  isCustom: boolean;
  createdAt: string;
  updatedAt: string;
};
```

### Origem de tarefa

```ts
type TaskOrigin = {
  taskId: string;
  originType:
    | 'company'
    | 'client'
    | 'contract'
    | 'position'
    | 'category'
    | 'group'
    | 'user'
    | 'manual';
  originId?: string | null;
};
```

### Vinculos de tarefa

```ts
type TaskRelation = {
  taskId: string;
  entityType: EntityType;
  entityId: string;
  relationType:
    | 'related'
    | 'responsible'
    | 'mentioned'
    | 'target'
    | 'source';
};
```

## Regras de Geracao Automatica

### Entrada

A funcao de geracao deve receber, no minimo:

```ts
generateVisualIdentity({
  projectId,
  entityType,
  entityId,
});
```

### Saida

A funcao deve retornar uma identidade visual completa:

```ts
{
  shape,
  primaryColor,
  secondaryColors,
  pattern,
  variantIndex,
  isCustom: false,
}
```

### Processo

1. Identificar o tipo da entidade.
2. Determinar a forma obrigatoria daquele tipo.
3. Determinar a familia de cor ou padrao permitida.
4. Buscar identidades ja usadas no mesmo projeto e tipo.
5. Selecionar a primeira opcao livre ou uma opcao pseudoaleatoria livre,
   conforme regra do tipo.
6. Quando o lote inicial estiver esgotado, gerar ou liberar novo lote de
   variacoes.
7. Validar contraste minimo.
8. Persistir a identidade visual.
9. Retornar a identidade para a interface.

### Escopo de unicidade

A regra de nao repeticao deve ser aplicada, por padrao, dentro do projeto.

```txt
Projeto A pode ter Empresa X com azul petroleo.
Projeto B tambem pode ter outra Empresa Y com azul petroleo.
Dentro do mesmo projeto, o sistema tenta evitar repeticao.
```

### Variacoes apos esgotamento

Quando uma familia visual esgotar as opcoes iniciais, o sistema deve criar um
novo lote mantendo as mesmas caracteristicas.

Exemplo para empresas:

```txt
Lote 1: 7 cores frias e escuras principais.
Lote 2: 7 cores frias e escuras com leve variacao de matiz ou luminosidade.
Lote 3: 7 novas cores frias e escuras, preservando contraste e distincao.
```

As variacoes devem ser suficientemente diferentes para leitura humana. Pequenas
mudancas imperceptiveis de saturacao ou luminosidade nao devem contar como nova
opcao.

### Edicao manual

Ao editar uma identidade visual, a interface deve:

- mostrar a sugestao atual;
- permitir trocar cor, gradiente ou padrao conforme o tipo;
- manter a forma fixa por tipo, salvo decisao explicita de produto;
- alertar quando a escolha for muito parecida com outra entidade do projeto;
- bloquear ou alertar escolhas com contraste insuficiente;
- gravar `isCustom: true` quando houver ajuste manual.

## Componentes de Interface

### EntityMarker

Componente minimo de identidade visual.

Responsabilidades:

- renderizar a forma;
- aplicar cor, gradiente ou padrao;
- respeitar tamanho padrao;
- oferecer label acessivel.

Uso:

```txt
listas densas, avatar compacto, mensagens, chips, tabelas
```

### EntityBadge

Componente com marcador e texto.

Responsabilidades:

- mostrar `EntityMarker`;
- mostrar nome curto da entidade;
- opcionalmente mostrar tipo textual;
- comportar tooltip com detalhes.

Uso:

```txt
cabecalhos, detalhes, cards de lista, filtros
```

### EntityChip

Versao compacta para vinculos secundarios.

Responsabilidades:

- indicar relacao sem dominar o layout;
- truncar texto com tooltip quando necessario;
- manter forma e cor reconheciveis.

Uso:

```txt
vinculos de tarefas, resultados de busca, filtros aplicados
```

### TaskOriginBadge

Componente dedicado para origem de tarefa.

Responsabilidades:

- destacar origem principal;
- diferenciar origem de vinculo;
- indicar quando a origem for manual ou desconhecida.

Uso:

```txt
kanban, calendario, detalhe de tarefa, notificacoes
```

### VisualIdentityPicker

Componente de edicao.

Responsabilidades:

- mostrar sugestoes disponiveis;
- permitir ajuste manual;
- validar contraste;
- indicar semelhanca com identidades existentes;
- respeitar restricoes de cada tipo.

Uso:

```txt
cadastro e edicao de empresa, cliente, contrato, posicao, categoria e grupo
```

### LegendPanel

Componente auxiliar para telas com alta densidade de entidades.

Responsabilidades:

- explicar formas usadas na tela;
- permitir filtro por tipo;
- ajudar leitura em chats, Network e dashboards.

Uso:

```txt
Network, chat com varios participantes, paineis operacionais
```

## Uso por Area do Produto

### Tarefas

Em tarefas, a origem deve ser exibida antes dos vinculos.

Exemplo:

```txt
[hexagono] Empresa - Pariflow
Revisar contrato de implantacao

Vinculos:
[pentagono] Joao Silva
[losango] Implantacao 2026
[circulo] Documentos
```

Regras:

- a origem aparece no cabecalho da tarefa;
- vinculos aparecem abaixo ou em uma linha secundaria;
- em visualizacoes compactas, exibir origem e contador de vinculos;
- no detalhe, listar todos os vinculos com tipo e nome.

### Chats

Em chats com participantes de tipos diferentes, cada participante deve manter
sua identidade visual.

Regras:

- mensagens exibem marcador do participante ou entidade representada;
- mencoes a entidades usam `EntityChip`;
- a lista de participantes pode agrupar por tipo;
- tooltip deve mostrar tipo, nome e papel no chat;
- quando o participante for usuario humano vinculado a uma entidade, a
  interface deve diferenciar usuario e entidade representada.

Exemplo:

```txt
[pentagono] Joao Silva
[hexagono] Pariflow
[losango] Contrato Implantacao 2026
```

### Notificacoes

Notificacoes devem usar a versao mais compacta possivel sem perder contexto.

Exemplo:

```txt
[hexagono] Pariflow criou uma nova tarefa.
```

Regras:

- origem principal aparece no inicio;
- texto deve mencionar a acao;
- detalhes adicionais aparecem ao expandir;
- evitar empilhar muitos chips em notificacao curta.

### Calendario e Kanban

Regras:

- eventos derivados de tarefas mostram origem;
- chips secundarios ficam recolhidos quando o espaco for pequeno;
- filtros por tipo devem usar a mesma forma dos marcadores;
- conflitos de cor com status devem ser evitados.

### Network

Regras:

- nos do grafo devem usar forma por tipo;
- cor ou padrao identifica a entidade;
- legenda deve estar disponivel;
- zoom distante pode simplificar padroes, preservando forma e cor principal;
- zoom proximo pode mostrar nome, tipo e vinculos.

## Acessibilidade e Legibilidade

Regras obrigatorias:

- nao depender apenas de cor;
- manter texto ou label acessivel para leitores de tela;
- garantir contraste entre marcador e fundo;
- validar tema claro e escuro;
- testar tamanhos pequenos;
- evitar padroes com ruido excessivo;
- nao usar texto dentro do marcador quando o tamanho for pequeno;
- manter tooltip ou detalhe textual para confirmacao.

Recomendacoes:

- usar forma e texto juntos em fluxos criticos;
- reservar vermelho, verde e amarelo saturados para estados operacionais;
- evitar diferencas de cor muito sutis entre entidades do mesmo tipo;
- garantir que gradientes e padroes continuem legiveis em telas pequenas.

## Plano de Implementacao

### Fase 0 - Validacao de produto

Objetivo:

Confirmar os tipos de entidade que precisam de identidade visual no primeiro
ciclo.

Atividades:

- listar telas onde entidades aparecem misturadas;
- confirmar se grupos ou equipes existem como origem de tarefa;
- definir se usuario humano tera identidade propria ou herdara a entidade
  representada;
- definir quais cores devem permanecer reservadas para status;
- validar nomenclatura exibida para origem e vinculos.

Entregaveis:

- lista final de tipos atendidos no primeiro ciclo;
- decisao sobre grupo/equipe;
- lista de cores reservadas para status;
- criterios de aceite visual.

### Fase 1 - Contratos e enums

Objetivo:

Criar contratos internos para representar tipos, formas, padroes e familias de
cores.

Atividades:

- criar enum de `EntityType`;
- criar enum de `VisualShape`;
- criar enum de `VisualPattern`;
- criar configuracao por tipo de entidade;
- declarar paletas iniciais;
- declarar regras de lote e variacao;
- documentar fallback para entidades sem identidade.

Entregaveis:

- contrato de identidade visual;
- mapa `entityType -> shape`;
- mapa `entityType -> palette/pattern`;
- testes unitarios das regras puras, quando aplicavel.

### Fase 2 - Persistencia

Objetivo:

Armazenar a identidade visual de forma reutilizavel.

Recomendacao:

Usar uma tabela ou colecao dedicada, em vez de espalhar campos pelas tabelas de
empresa, cliente, contrato e demais entidades.

Estrutura sugerida:

```txt
visual_identities
- id
- project_id
- entity_type
- entity_id
- shape
- primary_color
- secondary_colors
- pattern
- variant_index
- is_custom
- created_at
- updated_at
```

Indices recomendados:

```txt
unique(project_id, entity_type, entity_id)
index(project_id, entity_type)
index(project_id, shape)
```

Atividades:

- criar migracao ou estrutura equivalente;
- criar leitura por entidade;
- criar leitura em lote por lista de entidades;
- garantir unicidade por projeto, tipo e entidade;
- definir estrategia de backfill para dados existentes.

Entregaveis:

- persistencia criada;
- entidades existentes com identidade visual gerada ou fallback;
- consulta em lote para evitar chamadas repetidas no front.

### Fase 3 - Servico de geracao

Objetivo:

Centralizar a criacao automatica de identidades visuais.

Atividades:

- implementar `generateVisualIdentity`;
- consultar identidades ja usadas no projeto;
- aplicar regra especifica por tipo;
- gerar novo lote quando necessario;
- validar contraste;
- persistir resultado;
- garantir idempotencia para a mesma entidade.

Regras importantes:

- se a entidade ja possui identidade visual, retornar a existente;
- se a identidade foi customizada, nao sobrescrever automaticamente;
- se a geracao falhar, usar fallback neutro e registrar erro;
- geracao concorrente deve respeitar unicidade.

Entregaveis:

- servico de geracao;
- testes de nao repeticao;
- testes de esgotamento de lote;
- testes de idempotencia.

### Fase 4 - APIs ou camada de dados

Objetivo:

Expor identidades visuais para as telas sem aumentar complexidade de cada
modulo.

Atividades:

- incluir identidade visual nas respostas de detalhe, quando fizer sentido;
- criar endpoint ou consulta em lote para identidades;
- permitir edicao manual;
- validar payload de cor, padrao e gradiente;
- proteger alteracoes por permissao adequada;
- registrar auditoria se identidade visual for considerada configuracao do
  projeto.

Contratos sugeridos:

```txt
GET /visual-identities?projectId=...&entityType=...
GET /visual-identities/batch
PATCH /visual-identities/:id
POST /visual-identities/generate
```

Entregaveis:

- leitura individual;
- leitura em lote;
- atualizacao manual;
- criacao automatica integrada ao cadastro de entidades.

### Fase 5 - Componentes visuais no front

Objetivo:

Criar os componentes reutilizaveis antes de aplicar nas telas.

Atividades:

- criar `EntityMarker`;
- criar `EntityBadge`;
- criar `EntityChip`;
- criar `TaskOriginBadge`;
- criar `VisualIdentityPicker`;
- criar `LegendPanel`, se houver necessidade em telas densas;
- validar tamanhos padrao;
- validar tema claro e escuro;
- definir labels acessiveis.

Entregaveis:

- componentes isolados;
- exemplos internos de uso;
- testes visuais ou verificacoes manuais nos principais tamanhos;
- fallback para entidade sem identidade visual.

### Fase 6 - Cadastro e edicao de entidades

Objetivo:

Adicionar a escolha e revisao da identidade visual nos fluxos de cadastro e
edicao.

Atividades:

- mostrar sugestao automatica no cadastro;
- permitir troca manual quando permitido;
- indicar quando a escolha ja esta em uso ou e muito parecida;
- bloquear escolhas invalidas, se necessario;
- salvar `isCustom: true` quando houver alteracao manual;
- preservar a forma fixa por tipo.

Entregaveis:

- cadastro com identidade sugerida;
- edicao com identidade atual;
- validacao de contraste e similaridade;
- persistencia da customizacao.

### Fase 7 - Tarefas: origem e vinculos

Objetivo:

Aplicar o conceito de origem principal e vinculos secundarios em tarefas.

Atividades:

- adicionar campos de origem na criacao de tarefa;
- capturar origem automaticamente quando a tarefa nasce em detalhe de entidade;
- permitir origem manual quando necessario;
- adicionar vinculos secundarios;
- renderizar `TaskOriginBadge`;
- renderizar `EntityChip` para vinculos;
- definir comportamento compacto para kanban, calendario e listas.

Entregaveis:

- tarefas com origem;
- tarefas com vinculos;
- UI diferenciando origem de vinculos;
- migracao ou fallback para tarefas antigas.

### Fase 8 - Chats e mencoes

Objetivo:

Usar a identidade visual para orientar conversas com participantes e entidades
misturadas.

Atividades:

- renderizar marcador do participante;
- diferenciar usuario humano de entidade representada;
- aplicar chips em mencoes a entidades;
- agrupar participantes por tipo, se fizer sentido;
- adicionar tooltip com tipo, nome e papel;
- validar leitura em mensagens curtas e longas.

Entregaveis:

- participantes com identidade visual;
- mencoes com `EntityChip`;
- tooltip de contexto;
- fallback para participantes sem entidade associada.

### Fase 9 - Network, calendario e paineis

Objetivo:

Expandir a linguagem visual para areas de alta densidade.

Atividades:

- aplicar forma por tipo nos nos do Network;
- ajustar legenda;
- aplicar origem em eventos de calendario;
- aplicar filtros por tipo;
- validar performance em listas grandes;
- simplificar padroes quando o tamanho visual for muito pequeno.

Entregaveis:

- Network com formas por tipo;
- calendario com origem visual;
- filtros consistentes;
- legenda quando a tela exigir.

### Fase 10 - Testes, revisao e consolidacao

Objetivo:

Garantir consistencia, acessibilidade e estabilidade antes de expandir o uso.

Atividades:

- testar geracao sem repeticao dentro do projeto;
- testar esgotamento de lote;
- testar edicao manual;
- testar contraste em tema claro e escuro;
- testar tarefas com origem e multiplos vinculos;
- testar chats com participantes de tipos diferentes;
- testar Network com volume realista;
- revisar textos, tooltips e labels acessiveis.

Entregaveis:

- suite minima de testes;
- checklist visual validado;
- ajustes de acessibilidade;
- guia de uso para novas telas.

## Ordem Recomendada de Execucao

1. Validar tipos e regras visuais com produto.
2. Criar contratos, paletas e servico de geracao.
3. Persistir identidades visuais.
4. Criar componentes visuais reutilizaveis.
5. Integrar cadastro e edicao de entidades.
6. Integrar tarefas com origem e vinculos.
7. Integrar chats e mencoes.
8. Expandir para Network, calendario e paineis.
9. Revisar acessibilidade e consistencia.
10. Consolidar documentacao de uso para novas telas.

## Riscos e Mitigacoes

| Risco | Impacto | Mitigacao |
| --- | --- | --- |
| Excesso de informacao visual | Interface ruidosa | Usar origem em destaque e vinculos secundarios compactos |
| Dependencia excessiva de cor | Baixa acessibilidade | Combinar forma, texto e tooltip |
| Paletas muito parecidas | Dificuldade de reconhecimento | Validar distancia visual e contraste |
| Conflito com cores de status | Ambiguidade operacional | Reservar cores criticas para status |
| Padroes complexos em tamanho pequeno | Perda de leitura | Simplificar padrao em marcadores pequenos |
| Implementacao duplicada por tela | Inconsistencia | Centralizar em componentes reutilizaveis |
| Origem confundida com vinculo | Erro de interpretacao | Exibir origem em posicao principal |
| Dados antigos sem identidade | Falhas visuais | Criar fallback e rotina de backfill |

## Criterios de Aceite

O primeiro ciclo deve ser considerado pronto quando:

- cada tipo de entidade suportado tiver forma definida;
- novas entidades receberem identidade visual automaticamente;
- identidades forem estaveis apos criacao;
- edicao manual estiver disponivel onde for necessario;
- tarefas diferenciarem origem principal e vinculos secundarios;
- componentes reutilizaveis forem usados nas telas integradas;
- a interface nao depender apenas de cor;
- houver fallback para dados antigos ou incompletos;
- a leitura funcionar em tema claro e escuro;
- telas densas continuarem legiveis.

## Estado da Implementacao no Front

Primeiro ciclo implementado no front:

- modelo publico `EntityVisualIdentity`;
- enums de tipo, forma e padrao visual;
- gerador deterministico `VisualIdentityGenerator`;
- paletas iniciais para empresa, cliente, contrato, posicao, categoria, grupo e
  usuario;
- marcador visual `EntityMarker`;
- badge visual `EntityBadge`;
- chip visual `EntityChip`;
- legenda operacional `VisualIdentityLegend`;
- renderizacao de hexagono, pentagono, losango achatado, quadrado, circulo,
  triangulo e escudo;
- suporte visual a padrao solido, pontilhado, gradiente, manchas organicas,
  ondas e mosaico;
- uso em Companies, Clients, Contracts, People, Timeline e Network;
- filtros rapidos por tipo visual na Timeline;
- selecao rapida de camada visual na Network;
- marcadores e tags com tratamento mais discreto, usando reducao visual e
  opacidade padrao em torno de 90%;
- testes de estabilidade do gerador e regras basicas de forma/padrao.

Segundo ciclo implementado no front:

- serializacao de `EntityVisualIdentity` para preparar integracao com API;
- sugestoes deterministicas de identidade visual por entidade;
- picker reutilizavel de identidade visual;
- validacao visual basica de contraste e similaridade dentro do mesmo tipo;
- persistencia local por dispositivo via `shared_preferences`;
- acao `Visual` em Companies, Clients, Contracts e People;
- aplicacao de customizacoes locais em listas, detalhes, Timeline e Network
  quando o cache local esta carregado;
- restauracao para identidade automatica;
- diferenciacao entre entidade especifica e tipo generico: chips de filtro e
  resumos por tipo nao usam cor/forma de entidade, enquanto a regua lateral da
  Network preserva apenas forma neutra como referencia espacial;
- testes de sugestoes e serializacao.

Limitacoes do primeiro ciclo:

- a identidade ainda e gerada no front, sem persistencia propria no backend;
- a regra de nao repeticao absoluta dentro do projeto ainda depende de uma
  camada persistida de backend;
- edicao manual ja existe no front como preferencia local por dispositivo, mas
  ainda nao e persistida na tabela/colecao `visual_identities`;
- origem principal de tarefas ainda depende da existencia do modulo de tarefas
  e dos respectivos campos de origem;
- chats ainda nao foram integrados porque a tela/camada de chat nao esta no
  recorte atual do front.

## Direcao Final

O sistema deve ser implementado como uma camada formal de identidade visual de
entidades, e nao como estilos isolados por tela.

A estrutura recomendada e:

```txt
Entidade possui identidade visual.
Tarefa possui origem principal.
Tarefa possui vinculos secundarios.
Interface renderiza tudo por componentes reutilizaveis.
```

Essa abordagem permite que tarefas, chats, listas, Network, calendario e
paineis compartilhem a mesma linguagem visual, reduzindo ambiguidade quando
diferentes tipos de entidade aparecem no mesmo contexto.
