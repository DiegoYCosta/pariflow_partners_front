# Workspaces Operacionais

Data de referencia: `2026-05-15`.

Este documento consolida o planejamento antigo de Contracts, Clients e
Companies dentro da realidade atual do front. A versao externa citava mocks como
fonte de verdade; isso nao vale mais. O runtime atual usa API real e nao deve
reintroduzir fallback silencioso.

## Estado real

| Workspace | Endpoint base | Estado |
| --- | --- | --- |
| Companies | `empresas-prestadoras` | lista, detalhe, criar, editar e inativar |
| Clients | `clientes` | lista, detalhe, criar, editar e inativar |
| Contracts | `contratos` | contratos, catalogos, postos e documentos |

Regras comuns:

- usar `publicId` em todas as referencias entre telas e backend;
- tratar inativacao como mudanca de status, nao como perda de historico;
- mostrar empty/error state quando a API falhar, sem mock como fallback;
- manter tenant e empresa ativa vindos da sessao assinada pelo backend;
- nao aceitar rota, query string ou storage local como autoridade de empresa.

## Companies

O workspace de empresas prestadoras deve continuar focado em consulta rapida,
edicao controlada e leitura institucional.

Dados atuais vindos da API:

- `publicId`;
- `legalName`;
- `tradeName`;
- `document`;
- `status`;
- `contactsJson`;
- `addressJson`;
- `notes`;
- contadores em listagem: `contractCount`, `linkCount`, `occurrenceCount`.

Leitura esperada:

- lista com razao social, fantasia, documento, status e sinais de impacto
  operacional;
- detalhe no mesmo contexto da lista;
- acoes de editar e inativar sem apagar contratos, vinculos ou ocorrencias.

Quando o produto pedir mais contexto, o backend deve enriquecer o detalhe com
clientes conectados, contratos em foco, filas recentes e indicadores de risco.

## Clients

Clientes devem ter contexto proprio. Eles nao devem ficar escondidos dentro de
prestadoras ou contratos.

Dados atuais vindos da API:

- `publicId`;
- `name`;
- `document`;
- `clientType`;
- `addressJson`;
- `contactName`;
- `status`.

Leitura esperada:

- lista com nome, documento, tipo, contato e status;
- detalhe capaz de sustentar transicoes entre prestadoras quando o backend
  expuser esse contexto;
- copy e acoes mantendo a ideia de carteira operacional, nao cadastro isolado.

Pendente real:

- payload relacional nativo para prestadoras ativas/historicas;
- contratos em foco;
- pessoas impactadas;
- sinais de risco operacional.

## Contracts

Contratos devem costurar cliente, prestadora, tipo/modelo, postos e documentos.

Dados atuais vindos da API:

- `publicId`;
- `startsAt`, `endsAt`, `status`, `notes`;
- `contractType`;
- `contractModel`;
- `providerCompany`;
- `clientCompany`;
- `positions`;
- `documents`.

Leitura esperada:

- lista com vigencia, cliente, prestadora e status;
- detalhe com relacoes visiveis sem exigir varias telas intermediarias;
- postos e documentos tratados como extensoes do contrato;
- catalogos (`tipos`, `modelos`, `servicos`) usados para formularios reais.

## Backlog de integracao

1. Enriquecer detalhes de Companies e Clients somente quando houver tela que
   consuma o novo payload.
2. Preservar compatibilidade com listagens paginadas atuais.
3. Reutilizar os componentes de workspace existentes antes de criar variacoes.
4. Amarrar anexos sensiveis ao fluxo auditavel de acesso quando storage privado
   estiver em uso real.
5. Validar responsividade com dados reais, principalmente cards de detalhe.

## Material antigo nao migrado

Nao migrar para o repositorio:

- arquivos com chaves/configuracao Firebase literal;
- transcricoes de terminal;
- instrucoes de deploy anteriores ao checklist AWS atual;
- referencias a mock como fonte de verdade de runtime.
