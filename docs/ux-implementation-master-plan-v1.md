# Plano Mestre de Implementacao UX/IA v1

Data de referencia: `2026-07-12`.

Documento base externo: `D:\Users\DC\Downloads\PariFlow_Especificacao_UX_Arquitetura_Informacao_v1.md`.

Status: planejamento executivo e tecnico. Este documento orienta a
implementacao gradual da nova arquitetura de informacao sem declarar como
implementado o que ainda depende de backend, banco, validacao de dominio ou
teste com usuario.

## Autoridade documental

Ordem de autoridade para a proxima etapa:

1. Codigo real em `lib/`, `src/` e `prisma/`.
2. Especificacao UX/IA v1 de 10/07/2026.
3. Este plano mestre.
4. Contratos tecnicos novos documentados no backend.
5. Documentos antigos apenas quando nao conflitarem com a especificacao v1 nem
   com o codigo atual.

Se um documento antigo disser que algo planejado ja esta implementado, o codigo
real prevalece. Se codigo atual e especificacao v1 entrarem em conflito de
contrato, modelagem, tenant, ACL ou seguranca, a implementacao deve parar ate o
conflito ser resolvido.

## Objetivo da entrega

Transformar o PariFlow Partners em uma ferramenta operacional de Departamento
Pessoal centrada em:

- triagem diaria na Home;
- dossie funcional em Pessoas;
- agenda e diario operacional na Timeline;
- organizacao pessoal e compartilhada no Focus Board;
- navegacao contextual sem duplicar origem de dados;
- preservacao de publicId, tenant, ACL, auditoria e historico.

## Escopo e nao escopo

Escopo imediato:

- reorganizacao de UX existente;
- documentacao de contratos faltantes;
- separacao entre dado formal e informal;
- reducao de densidade visual sem remover funcionalidade;
- estados loading, vazio, erro e sem permissao;
- validacao dos dez fluxos prioritarios.

Fora do escopo imediato:

- implementar ferias e afastamentos como ocorrencia simples;
- implementar contrato de experiencia com regra legal fixa no front;
- converter nota em ocorrencia/evento sem contrato proprio;
- anexar arquivo a nota usando `occurrenceId` falso;
- tratar busca global visual como funcional antes do backend;
- usar documentos antigos como autoridade para reintroduzir mock.

## Mapa de conflitos conhecidos

| Area | Estado real | Conflito | Decisao |
| --- | --- | --- | --- |
| Focus Board notes | notas locais em `shared_preferences` | documentos descreviam compartilhamento/API | modelar backend proprio antes de migrar |
| Busca global | campo visual no header | sem comportamento funcional completo confirmado | planejar contrato e validar depois |
| Anexos | `Attachment` exige `occurrenceId` | nota nao pode ter anexo proprio seguro | fase futura de generalizacao |
| Home | dashboard real existente | precisa virar triagem diaria acionavel | evoluir payload de forma aditiva |
| Ferias/afastamentos | sem dominio validado | risco de virar ocorrencia/agenda simplificada | manter em backlog de dominio |
| Contrato de experiencia | sem fonte de calculo validada | risco de regra legal no front | backend deve calcular/refletir |

## Fases de implementacao

### Fase 0 - Medicao e validacao

Objetivo: medir o sistema atual antes de alterar fluxos centrais.

Entregas:

- roteiro dos dez fluxos prioritarios;
- linha de base de tempo e numero de interacoes;
- verificacao da busca global atual;
- inventario de estados loading/empty/error por tela;
- validacao de tenant e ACL em ambiente online;
- decisao de dominio para ferias, afastamentos e contrato de experiencia.

Bloqueios:

- sem usuario real ou dados representativos, nao declarar aceite integral;
- sem backend para Focus Board notes, nao declarar compartilhamento real.

### Fase 1 - Baixo risco e alinhamento visual

Objetivo: melhorar clareza sem alterar contratos.

Entregas:

- textos e terminologia em portugues operacional;
- titulos e acoes principais por workspace;
- filtros avancados recolhidos quando possivel;
- estados vazios e erros padronizados;
- Focus Board vazio menos dominante;
- Home com menos elementos sem acao.

Controles:

- nao mudar payload;
- nao remover rotas ou publicIds;
- nao criar novo shell.

### Fase 2 - Quatro telas centrais

Objetivo: reorganizar Home, Pessoas, Timeline e Focus Board.

Entregas:

- Home como central de triagem diaria;
- Pessoas em dossie funcional com abas claras;
- Timeline com modos Calendario, Agenda e Diario;
- Focus Board preparado para backend, com local apenas como legado/migracao.

Dependencias:

- contrato backend para itens de triagem;
- contrato backend para Focus Board notes;
- decisao de busca global.

### Fase 3 - Fluxos prioritarios

Objetivo: reduzir navegacao nos fluxos frequentes.

Entregas:

- localizar pessoa e abrir ficha;
- registrar ocorrencia;
- criar/selecionar vinculo;
- anexar documento formal;
- criar compromisso;
- criar nota/tarefa;
- retomar pendencias;
- links contextuais entre entidades.

Regra: atalhos contextuais abrem o fluxo canonico, nao formulario duplicado.

### Fase 4 - Padronizacao sistemica

Objetivo: aplicar consistencia a Companies, Clients, Contracts, Network e
Reports.

Entregas:

- headers de entidade;
- filtros rapidos e avancados;
- detalhes com relacoes resumidas;
- estados sem permissao;
- tabelas/listas com selecao persistente;
- acessibilidade e responsividade desktop/tablet.

### Fase 5 - Evolucoes funcionais

Objetivo: implementar dominios que exigem backend ou validacao juridica/DP.

Entregas candidatas:

- ferias e afastamentos como entidades proprias;
- contrato de experiencia com calculo e status no backend;
- conversao de nota em ocorrencia/evento;
- classificacao documental avancada;
- anexos diretos em nota;
- busca global completa;
- relatorios persistidos e jobs.

## Plano por tela

### Home

Origem atual: `GET /api/v1/dashboard/home`.

Alvo:

- cabecalho do dia;
- ate cinco prioridades autorizadas;
- proximos prazos acionaveis;
- itens para retomar;
- agenda imediata;
- acoes rapidas.

Dependencias:

- payload de triagem aditivo no dashboard;
- dados autorizados de Focus Board notes;
- links contextuais por publicId.

Nao fazer:

- graficos sem acao;
- listas permanentes estaticas;
- mostrar item sem permissao.

### Pessoas

Origem atual: API real de pessoas, vinculos, ocorrencias, tags, anexos e
agenda.

Alvo:

- lista com busca e filtros;
- cabecalho de ficha;
- abas Resumo, Vinculos, Historico funcional, Documentos, Agenda e Relacoes;
- notas relacionadas apenas quando autorizadas pelo backend;
- acoes principais: editar, registrar ocorrencia, anexar documento, criar
  compromisso.

Nao fazer:

- misturar nota informal no historico formal;
- criar contrato/posto dentro de Pessoas;
- tratar ferias/afastamentos como ocorrencia simples.

### Timeline, Agenda e Diario

Origem atual: `timeline`, `agenda`, `agenda/non-business-days` e preferencias
de calendario.

Alvo:

- modo Calendario mensal existente;
- modo Agenda para futuro;
- modo Diario para passado;
- gaveta de detalhe;
- filtros rapidos visiveis e avancados recolhidos.

Nao fazer:

- fundir tecnicamente Agenda e Timeline sem necessidade;
- editar reflexo de outro dominio fora da origem;
- usar cor como unico indicador.

### Focus Board

Origem atual: notas locais no front; Pessoas/Agenda via API real.

Alvo:

- notas/tarefas em backend com tenant, ACL e auditoria;
- estado recolhido/acoplado/destacado;
- filtros por status, contexto e visibilidade;
- migracao manual das notas locais;
- lembretes vinculados a Agenda por relacao explicita.

Documento tecnico: `focus-board-backend-integration-plan.md`.

Nao fazer:

- upload automatico de notas locais;
- compartilhar nota sem backend;
- anexar arquivo usando ocorrencia falsa;
- converter nota em registro formal sem acao explicita.

### Contratos

Origem atual: contratos, catalogos, postos e documentos.

Alvo:

- fonte principal de contrato, posto e documento contratual;
- links para pessoas alocadas, cliente e prestadora;
- alertas de vigencia apenas acionaveis;
- suporte futuro a contrato de experiencia calculado pelo backend.

Nao fazer:

- armazenar historico funcional da pessoa;
- duplicar formulario de contrato em Pessoas;
- calcular regra legal fixa no front.

### Empresas prestadoras e Clientes

Origem atual: workspaces mestre-detalhe com CRUD.

Alvo:

- resumo, contatos, contratos e relacoes quando houver dados;
- inativacao com impacto informado;
- acesso direto a contratos e pessoas vinculadas.

Nao fazer:

- transformar em dashboards paralelos;
- enriquecer payload antes de uma tela consumir o dado.

### Network

Origem atual: `GET /network/graph` e `GET /network/timeline`.

Alvo:

- analise e navegacao contextual;
- painel de detalhes por no;
- links para origem;
- filtros avancados sem ocupar area principal.

Nao fazer:

- editor primario de pessoa, contrato ou empresa;
- inferir eventos por texto no front;
- revelar notas privadas.

### Relatorios

Origem atual: `POST /api/v1/relatorios/executar`.

Alvo:

- acesso transversal pelo header;
- catalogo pesquisavel;
- filtros apos selecao do relatorio;
- resultado, metadata e CSV preservados.

Nao fazer:

- simular funcionalidade operacional ausente com relatorio;
- mover relatorios para menu principal comum.

### Busca global

Origem atual: campo visual no header.

Alvo:

- contrato backend dedicado;
- resultados agrupados;
- teclado completo;
- mascaramento de sensiveis;
- sem vazamento entre tenants;
- abrir entidade em ate 10 segundos em teste representativo.

Nao fazer:

- busca local agregando payloads de telas;
- expor historico recente sem regra de privacidade;
- retornar contagem de itens sem permissao.

## Backlog revisado

### Reorganizacao da experiencia existente

- Home de triagem;
- Pessoas em dossie;
- Timeline com calendario/agenda/diario;
- Focus Board preparado para backend;
- filtros avancados recolhidos;
- estados padronizados;
- textos e hierarquia;
- links contextuais.

### Evolucao funcional com backend

- Focus Board notes API;
- busca global;
- triagem de Home com itens autorizados;
- anexos diretos em nota;
- conversao de nota;
- classificacao documental avancada;
- ferias e afastamentos;
- contrato de experiencia;
- relatorios recorrentes.

### Validacao operacional

- usuarios reais;
- dados representativos;
- tenant isolation;
- tempo/interacoes dos fluxos;
- responsividade desktop/tablet;
- teste em `pariflowpartners.com.br`.

## Roteiro dos dez fluxos

Cada fluxo deve registrar: usuario, ambiente, data, tempo, interacoes, erro,
observacao e evidencia visual quando aplicavel.

1. Triagem do inicio do dia.
2. Localizar funcionario e abrir ficha.
3. Registrar ocorrencia.
4. Admissao e vinculo.
5. Anexar documento.
6. Criar compromisso.
7. Criar nota ou tarefa.
8. Ferias e afastamentos.
9. Acompanhar contrato de experiencia.
10. Fechar o dia.

Fluxos 8 e 9 permanecem pendentes de dominio antes de implementacao completa.

## Validacoes tecnicas por fase

Front:

- `dart analyze`
- `flutter test`
- `flutter build web --release`
- smoke com API local ou online;
- teste manual de refresh/logout;
- teste de estados loading/empty/error/sem permissao.

Back:

- `npm.cmd run lint`
- `npm.cmd run build`
- `npm.cmd run prisma:format`
- `npm.cmd run prisma:generate`
- `npm.cmd run prisma:migrate:status`
- smoke de endpoints protegidos.

Seguranca:

- usuario A nao ve nota privada do usuario B;
- tenant forjado por URL/body/query e ignorado ou rejeitado;
- `publicId` conhecido de outro tenant nao acessa dado;
- conteudo sensivel sem permissao nao revela titulo, resumo ou contagem;
- acoes formais gravam auditoria.

## Criterios de aceite do plano

- Nenhuma tela usa documento legado como autoridade contra a especificacao v1.
- Cada tipo de dado tem origem principal documentada.
- Atalhos contextuais reutilizam fluxo canonico.
- UX nova nao remove funcionalidade util existente.
- Contratos novos sao aditivos ou versionados.
- Notas informais permanecem separadas do historico formal.
- Focus Board compartilhado so e liberado apos backend com ACL.
- Busca global so e marcada como funcional apos contrato e validacao.
- Validacao operacional roda antes de aceite integral.

## Regras para atualizar este plano

- Atualizar quando contrato de API mudar.
- Atualizar quando uma fase for concluida.
- Registrar conflitos novos em "Mapa de conflitos conhecidos".
- Nao remover pendencia por otimismo; remover somente com evidencia no codigo,
  teste ou decisao documentada.
