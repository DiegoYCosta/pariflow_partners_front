# Focus Board - Plano de Integracao Backend

Data de referencia: `2026-07-12`.

Status: planejamento. O contrato backend alvo esta em
`D:\DEV\flutter\JOTABE\PariFlow Partners - Back\docs\focus-board-notes-contract.md`.

## Problema atual

O Focus Board do front tem experiencia rica de notas/tarefas, mas a fonte
primaria das notas ainda e local (`shared_preferences`). Isso nao atende ao
alvo de notas pessoais e compartilhadas com tenant, ACL e auditoria.

Enquanto o backend novo nao existir, o front nao deve declarar essas notas como
dado compartilhado seguro. A Agenda e os dados de Pessoas continuam vindo da
API real.

## Diretriz de integracao

- O front consome `/api/v1/focus-board/notes` somente depois do contrato backend
  estar implementado.
- Nao enviar tenant em rota, query, body ou storage.
- Nao criar ocorrencia, timeline ou agenda para simular nota.
- Nao migrar notas locais automaticamente.
- Quando a API falhar, mostrar erro recuperavel; nao cair para mock ou local
  silencioso como se fosse dado backend.
- Conteudo sem permissao nao aparece nem como contagem.

## Mapeamento de UI para contrato

| UI atual | Campo backend planejado |
| --- | --- |
| Nota simples | `kind=NOTE` |
| Tarefa/lembrete operacional | `kind=TASK` |
| Titulo | `title` |
| Descricao | `body` |
| Prioridade | `priority` |
| Somente eu / Compartilhada | `visibility` |
| Replicas/conclusao | `completionMode` e participantes |
| Pessoa/empresa/contrato relacionados | `contexts` |
| Filtros salvos | Preferencia local ou futura preferencia por usuario |
| Lixeira/arquivo | `status=TRASHED/ARCHIVED` |
| Auditoria visual | `GET /focus-board/notes/:publicId/events` |

## Adapter previsto

Criar adapter dedicado, sem acoplar widgets:

- `lib/features/focus_board/infrastructure/focus_board_api_data.dart`
- Modelos importaveis para note, participant, context, event e reminder.
- Repositorio com:
  - `listNotes(query)`
  - `getNote(publicId)`
  - `createNote(input)`
  - `updateNote(publicId, input)`
  - `completeNote(publicId)`
  - `reopenNote(publicId)`
  - `archiveNote(publicId)`
  - `trashNote(publicId)`
  - `restoreNote(publicId)`
  - `deleteNote(publicId)`
  - `listEvents(publicId)`
  - `createReminder(publicId, input)`
  - `deleteReminder(publicId, reminderPublicId)`

O controlador atual deve depender desse repositorio, nao de
`SharedPreferences`, quando a flag de backend estiver ativa.

## Migracao das notas locais

Nao fazer upload silencioso.

Fluxo seguro:

1. Detectar notas locais nao migradas apos login autenticado.
2. Exibir acao explicita para migrar.
3. Converter cada nota local para payload backend com `clientMigrationId`.
4. Enviar lote idempotente ou chamadas individuais idempotentes.
5. Marcar localmente como migrada somente apos sucesso.
6. Em erro parcial, preservar notas locais e listar quais falharam.
7. Depois da validacao, remover leitura local como fonte primaria.

## Estados de tela

O Focus Board deve ter estados separados:

- carregando API;
- vazio autorizado;
- erro de API com tentar novamente;
- sem permissao para nota especifica;
- migracao local pendente;
- migracao parcial com erro.

## Pontos que nao devem ser implementados no front antes do backend

- Nota compartilhada real.
- Contadores compartilhados.
- Anexo direto em nota.
- Conversao em ocorrencia ou evento.
- Busca global retornando notas.
- Filtros baseados em usuarios/grupos sem resposta backend.

## Ordem recomendada

1. Implementar e testar contrato backend.
2. Criar adapter front sem trocar UI inteira.
3. Trocar leitura/escrita do controlador para API.
4. Adicionar migracao manual das notas locais.
5. Expor notas relacionadas em Pessoas apenas com endpoint filtrado e ACL.
6. Expor itens para retomar na Home somente com dados autorizados.
7. Avaliar anexos diretos e conversoes como fases futuras.

## Validacoes obrigatorias

- `dart analyze`
- `flutter test`
- teste manual com dois usuarios no mesmo tenant: nota privada nao aparece.
- teste manual entre tenants: `publicId` conhecido nao acessa nota.
- falha de API nao carrega notas locais como se fossem backend.
- migracao local e idempotente.
