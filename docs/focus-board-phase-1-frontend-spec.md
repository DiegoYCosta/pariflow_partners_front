# Focus Board - Especificacao Front Fase 1

Data de referencia: `2026-07-12`.

Status: implementacao parcial em `2026-07-12`.

O adapter API, modelos internos e controlador com feature flag foram
implementados. A migracao manual de notas locais e a validacao smoke com dois
usuarios/tenants permanecem pendentes antes de ativar em producao sem ressalvas.

## Objetivo

Trocar a fonte primaria de notas/tarefas do Focus Board de `shared_preferences`
para `/api/v1/focus-board/notes`, preservando a experiencia atual e adicionando
estados seguros de API, permissao e migracao.

## Escopo

Entra:

- adapter API dedicado;
- modelos Dart importaveis;
- controlador usando backend quando flag ativa;
- estados loading, vazio, erro e sem permissao;
- criacao, edicao, conclusao, arquivo, lixeira e restauracao;
- listagem de eventos;
- migracao manual das notas locais;
- lembrete via endpoint de note reminders.

Nao entra:

- anexos diretos em nota;
- conversao em ocorrencia/evento;
- busca global retornando notas;
- fallback silencioso para local quando API falhar;
- compartilhamento real antes do backend.

## Arquivos previstos

- `lib/features/focus_board/infrastructure/focus_board_api_data.dart`
- `lib/features/focus_board/application/focus_board_notes_controller.dart`
- `lib/features/focus_board/domain/focus_board_note_models.dart`

Se a estrutura atual ainda estiver em `part`, a extracao deve ser conservadora e
sem refatoracao paralela.

## Estados de UI

- carregando API;
- vazio autorizado;
- erro com tentar novamente;
- nota sem permissao;
- modo local legado;
- migracao local pendente;
- migracao parcial;
- migracao concluida.

## Regra de fallback

Se backend estiver ativo e falhar:

- mostrar erro;
- nao renderizar nota local como se fosse backend;
- permitir alternar para "notas locais neste dispositivo" somente com rotulo
  explicito e sem compartilhamento.

## Criterio de pronto

- `dart analyze` passando.
- `flutter test` passando.
- nota privada de outro usuario nao aparece em smoke manual;
- falha de API nao carrega mock/local silencioso;
- migracao manual preserva notas em erro parcial.

## Estado implementado

- Feature flag: `PARIFLOW_FOCUS_BOARD_NOTES_API`.
- Flag desligada: mantem modo local legado.
- Flag ligada: usa `/api/v1/focus-board/notes` como fonte primaria e nao faz
  fallback silencioso para notas locais se a API falhar.
- Operacoes ligadas ao backend: listar, criar, editar, texto inline, concluir,
  reabrir, arquivar, mover para lixeira, restaurar, delete logico e eventos.
- Pendencia: UI de migracao manual das notas locais.
