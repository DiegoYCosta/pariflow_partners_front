# Calendario, Timeline, Lembretes e Relatorios

Data de referencia: `2026-05-14`.

- Focus Board cria e lista lembretes por colaborador.
- People carrega agenda associada a pessoa.
- Timeline e destino do shell CRM com visao mensal.
- Timeline lista registros de timeline, agenda e dias nao uteis.
- Timeline cria, edita e remove registros de timeline.
- Timeline e popup de Calendario salvam filtros/preferencias em
  `auth/preferences/calendar`, por usuario no tenant autenticado.
- Popup `Perfis e configuracoes > Calendario` lista agenda e dias nao uteis.
- O popup cria feriado/dia nao util por empresa/regiao/estado/cidade.
- O popup consulta aplicabilidade por `GET /api/v1/agenda/applicability`.
- Central de Relatorios executa `controls_calendar`.
- Relatorios retornam metadata, linhas, colunas e CSV quando backend suporta.

## Endpoints consumidos

- `GET /api/v1/agenda`
- `POST /api/v1/agenda`
- `PATCH /api/v1/agenda/:publicId`
- `DELETE /api/v1/agenda/:publicId`
- `GET /api/v1/agenda/non-business-days`
- `POST /api/v1/agenda/non-business-days`
- `DELETE /api/v1/agenda/non-business-days/:publicId`
- `GET /api/v1/agenda/applicability`
- `GET/POST/PATCH/DELETE /api/v1/timeline`
- `GET/PATCH /api/v1/auth/preferences/calendar`
- `POST /api/v1/relatorios/executar`

## Regras atuais

- O front usa `publicId` em todos os contratos de API.
- A API decide ACL, tenant e sensivel.
- Funcionarios desligados ficam fora de filtros de agenda por padrao, salvo
  query especifica.
- Feriados nacionais do Brasil aparecem como base ate 2050.
- Dias nao uteis adicionais podem ser cadastrados por escopo.
- Data de cadastro e data do evento/regra devem permanecer separadas.

## O que ainda falta

1. Visao semanal e diaria completas alem da visao mensal/lista.
2. Modal formal de filtros avancados estilo CMNET para Timeline/calendario.
3. Preview de audiencia antes de comunicado.
4. Confirmacao de ciencia.
5. Linha propria de dias nao uteis no relatorio quando o usuario quiser
   consultar somente feriados/dias nao uteis.
6. Persistencia de modelos de relatorio e jobs recorrentes.
7. Exportacao final para formatos alem do CSV retornado pela API.

## Criterios de validacao

- Criar feriado municipal com recorrencia anual.
- Criar lembrete com `1 dia util antes` e confirmar ajuste pelo backend.
- Abrir Timeline e ver agenda + dia nao util no mesmo mes.
- Executar `controls_calendar` com periodo e conferir metadata.
- Confirmar que falha de API nao carrega mock.
