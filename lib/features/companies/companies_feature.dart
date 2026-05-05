part of '../../app/app.dart';

class _CompaniesWorkspace extends StatefulWidget {
  const _CompaniesWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  State<_CompaniesWorkspace> createState() => _CompaniesWorkspaceState();
}

class _CompaniesWorkspaceState extends State<_CompaniesWorkspace> {
  final _EntityWorkspaceApiRepository _repository =
      _EntityWorkspaceApiRepository();
  final TextEditingController _searchController = TextEditingController();
  _EntityWorkspaceRuntimeData _runtimeData = _EntityWorkspaceRuntimeData.mock(
    _companiesWorkspaceData,
  );

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _runtimeData = _runtimeData.copyWith(isLoading: true);
    });

    try {
      final data = await _repository.loadProviderCompanies(
        search: _searchController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _runtimeData = data;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _runtimeData = _EntityWorkspaceRuntimeData.mock(
          _companiesWorkspaceData,
          errorMessage: _entityWorkspaceRuntimeErrorMessage(error, 'Companies'),
        );
      });
    }
  }

  Future<void> _runMutation(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      setState(() {
        _runtimeData = _runtimeData.copyWith(isLoading: true);
      });
      await action();
      await _loadCompanies();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _runtimeData = _runtimeData.copyWith(isLoading: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_peopleMutationErrorMessage(error)),
          backgroundColor: _roseColor,
        ),
      );
    }
  }

  Future<void> _openCreateCompanyDialog() async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ProviderCompanyCrudDialog(),
    );

    if (body == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await _runMutation(
      () => _repository.createProviderCompany(body),
      successMessage: 'Empresa prestadora criada na API.',
    );
  }

  Future<void> _openEditCompanyDialog(_EntityItem item) async {
    final snapshot = item.providerCompanySnapshot;
    if (snapshot == null) {
      _showEntityUnavailableAction(context);
      return;
    }

    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ProviderCompanyCrudDialog(initial: snapshot),
    );

    if (body == null || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.updateProviderCompany(item.publicId, body),
      successMessage: 'Empresa prestadora atualizada na API.',
    );
  }

  Future<void> _removeCompany(_EntityItem item) async {
    final confirmed = await _confirmEntityAction(
      context: context,
      title: 'Inativar prestadora',
      message:
          'A prestadora sera inativada sem apagar contratos, vinculos ou historico.',
      confirmLabel: 'Inativar',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _runMutation(
      () => _repository.removeProviderCompany(item.publicId),
      successMessage: 'Empresa prestadora inativada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _runtimeData.data;
    return _CompaniesRedesignedWorkspace(
      data: data,
      viewerProfile: widget.viewerProfile,
      selectedIndex: widget.selectedIndex,
      onSelectItem: widget.onSelectItem,
      sourceLabel: _runtimeData.sourceLabel,
      isLive: _runtimeData.isLive,
      isLoading: _runtimeData.isLoading,
      errorMessage: _runtimeData.errorMessage,
      searchController: _searchController,
      onSubmitSearch: _loadCompanies,
      onClearSearch: () {
        _searchController.clear();
        _loadCompanies();
      },
      onRefresh: _loadCompanies,
      onCreate: () {
        _openCreateCompanyDialog();
      },
      onEdit: (item) {
        _openEditCompanyDialog(item);
      },
      onRemove: (item) {
        _removeCompany(item);
      },
    );
  }
}

class _CompaniesRedesignedWorkspace extends StatelessWidget {
  const _CompaniesRedesignedWorkspace({
    required this.data,
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    required this.errorMessage,
    required this.searchController,
    required this.onSubmitSearch,
    required this.onClearSearch,
    required this.onRefresh,
    required this.onCreate,
    required this.onEdit,
    required this.onRemove,
  });

  final _EntityWorkspaceData data;
  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;
  final String sourceLabel;
  final bool isLive;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final ValueChanged<_EntityItem> onEdit;
  final ValueChanged<_EntityItem> onRemove;

  @override
  Widget build(BuildContext context) {
    final safeSelectedIndex = data.items.isEmpty
        ? 0
        : min(max(selectedIndex, 0), data.items.length - 1);
    final selectedItem = data.items.isEmpty
        ? null
        : data.items[safeSelectedIndex];
    final readableNoteCount = _companyReadableNoteCount(
      data.items,
      viewerProfile,
    );
    final readableAttachmentCount = _companyReadableAttachmentCount(
      data.items,
      viewerProfile,
    );

    return Column(
      children: [
        _CompaniesCommandHeader(
          data: data,
          sourceLabel: sourceLabel,
          isLive: isLive,
          isLoading: isLoading,
          readableNoteCount: readableNoteCount,
          readableAttachmentCount: readableAttachmentCount,
          searchController: searchController,
          onSubmitSearch: onSubmitSearch,
          onClearSearch: onClearSearch,
          onRefresh: onRefresh,
          onCreate: onCreate,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _EntityRuntimeNotice(message: errorMessage!, onRetry: onRefresh),
        ],
        const SizedBox(height: 22),
        if (selectedItem == null)
          _Panel(
            padding: const EdgeInsets.all(28),
            child: _CompanyEmptyState(onCreate: onCreate, isLoading: isLoading),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 1120;
              final listPanel = _Panel(
                padding: const EdgeInsets.all(20),
                child: _CompaniesDirectoryPanel(
                  data: data,
                  selectedIndex: safeSelectedIndex,
                  onSelectItem: onSelectItem,
                ),
              );
              final detailPanel = _Panel(
                padding: const EdgeInsets.all(24),
                child: _CompanyProfilePanel(
                  item: selectedItem,
                  viewerProfile: viewerProfile,
                  isLoading: isLoading,
                  onEdit: () => onEdit(selectedItem),
                  onRemove: () => onRemove(selectedItem),
                ),
              );

              if (stacked) {
                return Column(
                  children: [
                    listPanel,
                    const SizedBox(height: 22),
                    detailPanel,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: listPanel),
                  const SizedBox(width: 22),
                  Expanded(flex: 8, child: detailPanel),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _CompaniesCommandHeader extends StatelessWidget {
  const _CompaniesCommandHeader({
    required this.data,
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    required this.readableNoteCount,
    required this.readableAttachmentCount,
    required this.searchController,
    required this.onSubmitSearch,
    required this.onClearSearch,
    required this.onRefresh,
    required this.onCreate,
  });

  final _EntityWorkspaceData data;
  final String sourceLabel;
  final bool isLive;
  final bool isLoading;
  final int readableNoteCount;
  final int readableAttachmentCount;
  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              final titleBlock = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _tealColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _tealColor.withValues(alpha: 0.20),
                      ),
                    ),
                    child: const Icon(
                      Icons.apartment_outlined,
                      color: _tealColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Companies', style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text(
                          'Consulta e gestao de prestadoras com contexto operacional no mesmo workspace.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Tag(
                    label: sourceLabel,
                    icon: isLoading
                        ? Icons.sync_rounded
                        : isLive
                        ? Icons.cloud_done_outlined
                        : Icons.storage_outlined,
                    color: isLive ? _tealColor : _slateColor,
                    background: (isLive ? _tealColor : _slateColor).withValues(
                      alpha: 0.12,
                    ),
                  ),
                  IconButton.outlined(
                    tooltip: 'Sincronizar',
                    onPressed: isLoading ? null : onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  FilledButton.icon(
                    onPressed: isLoading ? null : onCreate,
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Nova prestadora'),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleBlock, const SizedBox(height: 16), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 18),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _ContextSearchField(
            controller: searchController,
            hintText: data.searchHint,
            accent: _tealColor,
            enabled: !isLoading,
            maxWidth: 620,
            onSubmitted: (_) => onSubmitSearch(),
            onClear: onClearSearch,
            onSearch: onSubmitSearch,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CompanyMetricPill(
                label: '${data.items.length} prestadoras',
                icon: Icons.dataset_outlined,
                color: _tealColor,
              ),
              _CompanyMetricPill(
                label: isLive ? 'dados da API' : 'preview local',
                icon: isLive
                    ? Icons.cloud_done_outlined
                    : Icons.storage_outlined,
                color: isLive ? _tealColor : _slateColor,
              ),
              if (readableNoteCount > 0)
                _CompanyMetricPill(
                  label: '$readableNoteCount notas visiveis',
                  icon: Icons.lock_open_rounded,
                  color: _roseColor,
                ),
              if (readableAttachmentCount > 0)
                _CompanyMetricPill(
                  label: '$readableAttachmentCount anexos visiveis',
                  icon: Icons.attach_file_rounded,
                  color: _amberColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyMetricPill extends StatelessWidget {
  const _CompanyMetricPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompaniesDirectoryPanel extends StatelessWidget {
  const _CompaniesDirectoryPanel({
    required this.data,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _EntityWorkspaceData data;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prestadoras', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Selecione uma empresa para manter o detalhe aberto ao lado.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _mutedColor,
                    ),
                  ),
                ],
              ),
            ),
            _CompanyCountBadge(count: data.items.length),
          ],
        ),
        const SizedBox(height: 18),
        for (final entry in data.items.indexed)
          _CompanyDirectoryTile(
            item: entry.$2,
            selected: entry.$1 == selectedIndex,
            onTap: () => onSelectItem(entry.$1),
          ),
      ],
    );
  }
}

class _CompanyCountBadge extends StatelessWidget {
  const _CompanyCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _tealColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _tealColor.withValues(alpha: 0.16)),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: _tealColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CompanyDirectoryTile extends StatelessWidget {
  const _CompanyDirectoryTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _EntityItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = item.providerCompanySnapshot;
    final document =
        snapshot?.document ?? _companyRelationValue(item, 'Documento');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected
                  ? item.color.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? item.color : _lineColor,
                width: selected ? 1.3 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: item.color),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              selected
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.chevron_right_rounded,
                              color: selected ? item.color : _mutedColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _mutedColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _CompanyMiniTag(
                              label: item.status,
                              icon: item.icon,
                              color: item.color,
                            ),
                            if (document.trim().isNotEmpty)
                              _CompanyMiniTag(
                                label: document,
                                icon: Icons.badge_outlined,
                                color: _slateColor,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyProfilePanel extends StatelessWidget {
  const _CompanyProfilePanel({
    required this.item,
    required this.viewerProfile,
    required this.isLoading,
    required this.onEdit,
    required this.onRemove,
  });

  final _EntityItem item;
  final _ViewerAccessProfile viewerProfile;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = item.providerCompanySnapshot;
    final legalName = _companyFirstText(snapshot?.legalName, item.title);
    final tradeName = _companyFirstText(snapshot?.tradeName, '');
    final document = _companyFirstText(
      snapshot?.document,
      _companyRelationValue(item, 'Documento'),
    );
    final email = _companyFirstText(snapshot?.email, '');
    final phone = _companyFirstText(snapshot?.phone, '');
    final contracts = _companyRelationValue(item, 'Contratos conectados');
    final links = _companyRelationValue(item, 'Vinculos carregados');
    final occurrences = _companyRelationValue(item, 'Ocorrencias relacionadas');
    final updatedAt = _companyRelationValue(item, 'Atualizado em');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _CompanyMiniTag(
                      label: item.status,
                      icon: item.icon,
                      color: item.color,
                    ),
                    _CompanyMiniTag(
                      label: item.publicId,
                      icon: Icons.tag_outlined,
                      color: _slateColor,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(legalName, style: theme.textTheme.headlineSmall),
                if (tradeName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    tradeName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _mutedColor,
                    ),
                  ),
                ],
              ],
            );
            final actions = Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onRemove,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Inativar'),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 16), actions],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: 18),
                actions,
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        _CompanyInfoGrid(
          cells: [
            _CompanyInfoCellData(
              label: 'Documento',
              value: _companyValueOrDash(document),
              icon: Icons.badge_outlined,
            ),
            _CompanyInfoCellData(
              label: 'Status de dominio',
              value: _companyFirstText(snapshot?.status, item.status),
              icon: Icons.verified_outlined,
            ),
            _CompanyInfoCellData(
              label: 'Contratos',
              value: _companyValueOrDash(contracts),
              icon: Icons.description_outlined,
            ),
            _CompanyInfoCellData(
              label: 'Vinculos',
              value: _companyValueOrDash(links),
              icon: Icons.people_outline_rounded,
            ),
            _CompanyInfoCellData(
              label: 'Ocorrencias',
              value: _companyValueOrDash(occurrences),
              icon: Icons.report_problem_outlined,
            ),
            _CompanyInfoCellData(
              label: 'Atualizacao',
              value: _companyValueOrDash(updatedAt),
              icon: Icons.update_outlined,
            ),
          ],
        ),
        if (email.isNotEmpty || phone.isNotEmpty) ...[
          const SizedBox(height: 22),
          _CompanyContactStrip(email: email, phone: phone),
        ],
        const SizedBox(height: 22),
        _CompanyNarrativeBlock(
          title: 'Leitura operacional',
          icon: Icons.insights_outlined,
          child: Text(
            item.detailSummary,
            style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
          ),
        ),
        if (snapshot != null && snapshot.notes.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _CompanyNarrativeBlock(
            title: 'Notas cadastrais',
            icon: Icons.notes_outlined,
            accent: _amberColor,
            child: Text(
              snapshot.notes.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
            ),
          ),
        ],
        const SizedBox(height: 22),
        _CompanyRelationsSection(item: item),
        const SizedBox(height: 22),
        _CompanyProtectedSection(item: item, viewerProfile: viewerProfile),
      ],
    );
  }
}

class _CompanyInfoCellData {
  const _CompanyInfoCellData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _CompanyInfoGrid extends StatelessWidget {
  const _CompanyInfoGrid({required this.cells});

  final List<_CompanyInfoCellData> cells;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final columns = constraints.maxWidth < 620 ? 1 : 3;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final cell in cells)
              SizedBox(
                width: width,
                child: _CompanyInfoCell(cell: cell),
              ),
          ],
        );
      },
    );
  }
}

class _CompanyInfoCell extends StatelessWidget {
  const _CompanyInfoCell({required this.cell});

  final _CompanyInfoCellData cell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cell.icon, size: 17, color: _tealColor),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  cell.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _mutedColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            cell.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyContactStrip extends StatelessWidget {
  const _CompanyContactStrip({required this.email, required this.phone});

  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tealColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _tealColor.withValues(alpha: 0.14)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (email.isNotEmpty)
            _CompanyContactItem(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: email,
            ),
          if (phone.isNotEmpty)
            _CompanyContactItem(
              icon: Icons.call_outlined,
              label: 'Telefone',
              value: phone,
            ),
        ],
      ),
    );
  }
}

class _CompanyContactItem extends StatelessWidget {
  const _CompanyContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 360),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _tealColor.withValues(alpha: 0.14)),
            ),
            child: Icon(icon, size: 18, color: _tealColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _mutedColor,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _inkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyNarrativeBlock extends StatelessWidget {
  const _CompanyNarrativeBlock({
    required this.title,
    required this.icon,
    required this.child,
    this.accent = _tealColor,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 19),
              const SizedBox(width: 9),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(color: _inkColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CompanyRelationsSection extends StatelessWidget {
  const _CompanyRelationsSection({required this.item});

  final _EntityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relacoes principais', style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),
        for (final relation in item.relations)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: _tealColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_outward_rounded,
                    size: 15,
                    color: _tealColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    relation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _inkColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CompanyProtectedSection extends StatelessWidget {
  const _CompanyProtectedSection({
    required this.item,
    required this.viewerProfile,
  });

  final _EntityItem item;
  final _ViewerAccessProfile viewerProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleNotes = [...item.sensitiveNotes]
      ..retainWhere((note) => note.accessPolicy.canViewerRead(viewerProfile))
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    final visibleAttachments = item.attachments
        .where(
          (attachment) => attachment.accessPolicy.canViewerRead(viewerProfile),
        )
        .toList();
    final hasVisibleContent =
        visibleNotes.isNotEmpty || visibleAttachments.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Memoria protegida', style: theme.textTheme.titleLarge),
              _CompanyMiniTag(
                label: viewerProfile.isAuthenticated
                    ? viewerProfile.managementSummary
                    : 'consulta autenticada',
                icon: viewerProfile.isAuthenticated
                    ? Icons.rule_folder_outlined
                    : Icons.lock_outline_rounded,
                color: viewerProfile.canViewSensitive ? _tealColor : _roseColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasVisibleContent
                ? 'Abaixo aparecem somente notas e anexos liberados para este perfil.'
                : 'Nenhum conteudo protegido esta visivel para este perfil no recorte selecionado.',
            style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
          ),
          if (visibleAttachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Anexos acessiveis', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final attachment in visibleAttachments)
              _CompanyProtectedItem(
                title: attachment.title,
                summary: attachment.summary,
                tagLabel: attachment.classification.label,
                tagIcon: attachment.classification.icon,
                tagColor: attachment.classification.color,
                meta: '${attachment.status} | ${attachment.updatedAtLabel}',
              ),
          ],
          if (visibleNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Notas sensiveis', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final note in visibleNotes)
              _CompanyProtectedItem(
                title: note.label,
                summary: note.note,
                tagLabel: note.classification.label,
                tagIcon: note.classification.icon,
                tagColor: note.color,
                meta: note.accessSummary,
              ),
          ],
        ],
      ),
    );
  }
}

class _CompanyProtectedItem extends StatelessWidget {
  const _CompanyProtectedItem({
    required this.title,
    required this.summary,
    required this.tagLabel,
    required this.tagIcon,
    required this.tagColor,
    required this.meta,
  });

  final String title;
  final String summary;
  final String tagLabel;
  final IconData tagIcon;
  final Color tagColor;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              _CompanyMiniTag(label: tagLabel, icon: tagIcon, color: tagColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: theme.textTheme.labelMedium?.copyWith(color: _mutedColor),
          ),
        ],
      ),
    );
  }
}

class _CompanyMiniTag extends StatelessWidget {
  const _CompanyMiniTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyEmptyState extends StatelessWidget {
  const _CompanyEmptyState({required this.onCreate, required this.isLoading});

  final VoidCallback onCreate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _tealColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.search_off_rounded, color: _tealColor),
        ),
        const SizedBox(height: 14),
        Text(
          'Nenhuma prestadora encontrada',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'A busca nao retornou registros neste recorte. Voce pode limpar a consulta ou cadastrar uma nova prestadora.',
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: isLoading ? null : onCreate,
          icon: const Icon(Icons.add_business_outlined),
          label: const Text('Nova prestadora'),
        ),
      ],
    );
  }
}

int _companyReadableNoteCount(
  List<_EntityItem> items,
  _ViewerAccessProfile viewerProfile,
) {
  return items.fold<int>(
    0,
    (total, item) =>
        total +
        item.sensitiveNotes
            .where((note) => note.accessPolicy.canViewerRead(viewerProfile))
            .length,
  );
}

int _companyReadableAttachmentCount(
  List<_EntityItem> items,
  _ViewerAccessProfile viewerProfile,
) {
  return items.fold<int>(
    0,
    (total, item) =>
        total +
        item.attachments
            .where(
              (attachment) =>
                  attachment.accessPolicy.canViewerRead(viewerProfile),
            )
            .length,
  );
}

String _companyRelationValue(_EntityItem item, String label) {
  final prefix = '$label:';
  for (final relation in item.relations) {
    if (relation.startsWith(prefix)) {
      return relation.substring(prefix.length).trim();
    }
  }
  return '';
}

String _companyFirstText(String? primary, String fallback) {
  final trimmed = primary?.trim() ?? '';
  return trimmed.isEmpty ? fallback.trim() : trimmed;
}

String _companyValueOrDash(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? '-' : trimmed;
}

class _ProviderCompanyCrudDialog extends StatefulWidget {
  const _ProviderCompanyCrudDialog({this.initial});

  final _ProviderCompanyCrudSnapshot? initial;

  @override
  State<_ProviderCompanyCrudDialog> createState() =>
      _ProviderCompanyCrudDialogState();
}

class _ProviderCompanyCrudDialogState
    extends State<_ProviderCompanyCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _legalName = TextEditingController();
  final TextEditingController _tradeName = TextEditingController();
  final TextEditingController _document = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  String _status = 'ACTIVE';

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _legalName.text = initial.legalName;
      _tradeName.text = initial.tradeName;
      _document.text = initial.document;
      _email.text = initial.email;
      _phone.text = initial.phone;
      _notes.text = initial.notes;
      _status = initial.status.isEmpty ? 'ACTIVE' : initial.status;
    }
  }

  @override
  void dispose() {
    _legalName.dispose();
    _tradeName.dispose();
    _document.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Editar prestadora' : 'Nova prestadora'),
      content: SizedBox(
        width: min(MediaQuery.sizeOf(context).width - 48, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(
                  controller: _legalName,
                  label: 'Razao social',
                  icon: Icons.apartment_outlined,
                  required: true,
                ),
                _dialogTextField(
                  controller: _tradeName,
                  label: 'Nome fantasia',
                  icon: Icons.storefront_outlined,
                ),
                _dialogTextField(
                  controller: _document,
                  label: 'Documento',
                  icon: Icons.badge_outlined,
                  required: true,
                ),
                _dialogDropdown(
                  label: 'Status',
                  value: _status,
                  icon: Icons.verified_outlined,
                  values: const ['ACTIVE', 'INACTIVE', 'SUSPENDED'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dialogTextField(
                        controller: _email,
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogTextField(
                        controller: _phone,
                        label: 'Telefone',
                        icon: Icons.call_outlined,
                      ),
                    ),
                  ],
                ),
                _dialogTextField(
                  controller: _notes,
                  label: 'Notas',
                  icon: Icons.notes_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_editing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final contacts = <String, String>{
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
    };

    Navigator.of(context).pop(
      _cleanMutationBody({
        'legalName': _legalName.text,
        'tradeName': _tradeName.text,
        'document': _document.text,
        'status': _status,
        if (contacts.isNotEmpty) 'contactsJson': contacts,
        'notes': _notes.text,
      }),
    );
  }
}
