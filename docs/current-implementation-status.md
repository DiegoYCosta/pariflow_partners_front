# Estado Atual e Proximos Passos

Data de referencia: `2026-05-14`.

O projeto ja tem front e backend integrados nos modulos operacionais centrais.
A fase atual nao e criar shell, CRUD basico, People, Network ou agenda. A fase
atual e validar dados reais, fechar login online, dominio/HTTPS, relatorios e
acabamento operacional.

## Front

| Area | Estado atual | Pendente real |
| --- | --- | --- |
| Shell CRM | variante principal ativa | refinamento responsivo |
| Home | consome `GET /dashboard/home` | validar indicadores com base real |
| Companies | lista, detalhe, criar, editar e inativar | enriquecer detalhes quando necessario |
| Clients | lista, detalhe, criar, editar e inativar | payload relacional nativo quando a tela pedir |
| Contracts | contratos, tipos, modelos, servicos, postos e documentos | validar regras reais |
| People | pessoa, vinculos, ocorrencias, tags, anexos e agenda | validar responsividade com dados reais |
| Focus Board | hub persistente, desacoplavel, agenda e anexos auditaveis | responsividade mobile/tablet |
| Timeline | calendario mensal com timeline, agenda, dias nao uteis e filtros salvos | UX de audiencia |
| Relatorios | catalogo e execucao real de templates suportados | exportacao/auditoria final |
| Network | consome `GET /network/graph` | performance, ACL fina e acabamento visual |
| Auth | Firebase Web, refresh/logout no cliente, onboarding publico e seletor multiempresa | usuarios reais e smoke online |
| Identidade visual | gerador, componentes, picker e cache local | persistencia backend |

## Backend

| Area | Estado atual | Pendente real |
| --- | --- | --- |
| Auth | exchange, `/me`, `PATCH /me`, refresh rotativo, logout, step-up e contexto multiempresa | UX final de refresh/logout em HTTPS |
| Tenant | escopo por empresa raiz selecionada em services principais | validacao com usuarios reais |
| Dashboard | `GET /dashboard/home` ativo | ajustar metricas com uso real |
| Operacao | CRUDs centrais ativos | enriquecer payloads pontuais |
| People/dossie | pessoas, vinculos, ocorrencias, tags e anexos auditaveis | validacao com usuarios reais |
| Timeline | CRUD de registros com vinculos e filtros salvos | relatorios derivados |
| Agenda | compromissos, lembretes, `NOTICE`, dias nao uteis e aplicabilidade | preview de audiencia e ciencia |
| Relatorios | templates suportados, metadata e CSV | modelos persistidos, exportacao final e jobs |
| Network | grafo relacional ativo | volume, paginacao e ACL fina |
| AWS | homologacao por IP com Apache/PM2/MySQL | dominio, HTTPS e backups |

## O que saiu do backlog

- dual shell como decisao aberta;
- dashboard CRM inicial;
- modulo de clientes;
- workspaces de Companies, Clients, Contracts e People;
- CRUD operacional dos modulos mestre;
- catalogo de contratos;
- endpoint backend de Network;
- Focus Board com agenda;
- Timeline e calendario mensal operacional;
- Central de Relatorios com execucao real;
- outbox de notificacao;
- mocks como fallback silencioso;
- Swagger publico em AWS;
- bypass de auth em host publico.

## Ordem recomendada agora

1. Finalizar DNS/HTTPS na AWS e validar `https://pariflowpartners.com.br`.
2. Criar usuarios reais e conceder perfis internos.
3. Rodar smoke de login real ponta a ponta, incluindo selecao de empresa e
   tentativa de tenant forjado.
4. Validar CRUDs, Timeline, relatorios e Network com dados reais.
5. Corrigir divergencias especificas de payload/tela.
6. Fechar refresh/logout na UX final ja com cookie `Secure`.
7. Evoluir calendario com preview de audiencia e ciencia.
8. Persistir identidade visual no backend.
9. Definir backup/restore de banco.

Pendencias novas precisam ser especificas por endpoint, payload, tela ou regra.
