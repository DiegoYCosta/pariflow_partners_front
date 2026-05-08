part of '../../app/app.dart';

const _companiesWorkspaceMeta = _EntityWorkspaceData(
  title: 'Empresas com workspace focado',
  subtitle:
      'Consulta empresarial limpa, com lista e detalhe no mesmo contexto.',
  searchHint: 'buscar por razao social, fantasia ou documento',
  listHint:
      'A lista usa somente registros carregados da API real para abrir o detalhe ao lado.',
  productionHint:
      'Runtime real: listar empresas por API, abrir detalhe autenticado e manter dados sensiveis protegidos.',
  integrationFocus: [
    'API real',
    'lista paginada',
    'detalhe autenticado',
    'sem mock',
  ],
  filters: ['ativas', 'com contratos em aberto', 'multiempresa'],
  accent: _tealColor,
  items: <_EntityItem>[],
);

const _clientCompaniesWorkspaceMeta = _EntityWorkspaceData(
  title: 'Empresas clientes com contexto proprio',
  subtitle: 'Gerencie as empresas envolvidas em seu flow.',
  searchHint: 'buscar por nome da carteira, documento ou unidade',
  listHint:
      'A lista cruza prestadoras, contratos e contexto operacional somente quando a API real entregar registros.',
  productionHint:
      'Runtime real: clientes, prestadoras e contratos preservados por payload autenticado.',
  integrationFocus: [
    'API real',
    'carteira de clientes',
    'contratos relevantes',
    'sem mock',
  ],
  filters: ['ativos', 'multi-prestadora', 'com transicao recente'],
  accent: _slateColor,
  items: <_EntityItem>[],
);

const _contractsWorkspaceMeta = _EntityWorkspaceData(
  title: 'Contratos com leitura contextual',
  subtitle:
      'Consulta contratual organizada por vigencia, cliente, prestadora e pessoas impactadas.',
  searchHint: 'buscar por cliente, prestadora ou codigo do contrato',
  listHint:
      'A lista destaca vigencia, empresa relacionada e impacto operacional a partir da API real.',
  productionHint:
      'Runtime real: vigencia, cliente e prestadora consolidados no mesmo payload autenticado.',
  integrationFocus: ['API real', 'vigencia', 'cliente', 'prestadora'],
  filters: ['vigentes', 'a vencer', 'com rotacao recente'],
  accent: _amberColor,
  items: <_EntityItem>[],
);

const _peopleWorkspaceMeta = _EntityWorkspaceData(
  title: 'Funcionarios com ficha mais legivel',
  subtitle:
      'Consulta de pessoas com separacao entre registro-base, vinculo, empresa e historico.',
  searchHint: 'buscar por nome, cpf, email ou telefone',
  listHint:
      'A lista abre fichas vindas da API real sem preencher lacunas com dados locais.',
  productionHint:
      'Runtime real: pessoas, vinculos, tags e anexos protegidos lidos do backend.',
  integrationFocus: ['API real', 'vinculos', 'tags protegidas', 'sem mock'],
  filters: ['ativos', 'desligados recentes', 'mais de um vinculo'],
  accent: _roseColor,
  items: <_EntityItem>[],
);
