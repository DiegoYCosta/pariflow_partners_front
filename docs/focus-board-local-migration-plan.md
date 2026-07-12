# Focus Board - Plano Front de Migracao Local

Data de referencia: `2026-07-12`.

Status: planejamento. Complementa o plano backend de migracao.

## Deteccao

O front deve detectar notas locais em `shared_preferences` que nao possuem:

- `remotePublicId`;
- `migratedAt`;
- `migrationIgnoredAt`.

## UI

Mostrar estado compacto:

- quantidade local encontrada;
- aviso de que a migracao e manual;
- acao "Migrar notas locais";
- acao "Agora nao".

Nao mostrar conteudo de notas na tela de confirmacao se houver risco de
compartilhamento de tela.

## Envio

Para cada nota:

- garantir `clientMigrationId`;
- converter campos para DTO backend;
- usar `visibility=PRIVATE` por padrao;
- enviar individualmente para permitir recuperacao parcial;
- gravar `remotePublicId` em sucesso.

## Erro parcial

Manter lista local com status:

- migrada;
- falhou;
- ignorada;
- pendente.

Usuario pode tentar novamente apenas falhas.

## Remocao futura do local

Somente remover leitura local como fonte primaria depois de:

- backend estavel;
- migracao validada;
- release online testado;
- backup/exportacao manual definido se necessario.
