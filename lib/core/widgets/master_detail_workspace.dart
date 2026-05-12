part of '../../app/app.dart';

class _EntityWorkspace extends StatelessWidget {
  const _EntityWorkspace({
    required this.data,
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
    this.sourceLabel,
    this.isLive = false,
    this.isLoading = false,
    this.errorMessage,
    this.searchController,
    this.onSubmitSearch,
    this.onClearSearch,
    this.onRefresh,
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.onPrimaryAction,
  });

  final _EntityWorkspaceData data;
  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;
  final String? sourceLabel;
  final bool isLive;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController? searchController;
  final VoidCallback? onSubmitSearch;
  final VoidCallback? onClearSearch;
  final VoidCallback? onRefresh;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final safeSelectedIndex = data.items.isEmpty
        ? 0
        : min(max(selectedIndex, 0), data.items.length - 1);
    final selectedItem = data.items.isEmpty
        ? null
        : data.items[safeSelectedIndex];
    final readableNoteCount = data.items.fold<int>(
      0,
      (total, item) =>
          total +
          item.sensitiveNotes
              .where((note) => note.accessPolicy.canViewerRead(viewerProfile))
              .length,
    );
    final readableAttachmentCount = data.items.fold<int>(
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
    final itemsWithReadableSensitiveContent = data.items.where((item) {
      final noteMatch = item.sensitiveNotes.any(
        (note) => note.accessPolicy.canViewerRead(viewerProfile),
      );
      final attachmentMatch = item.attachments.any(
        (attachment) => attachment.accessPolicy.canViewerRead(viewerProfile),
      );
      return noteMatch || attachmentMatch;
    }).length;

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final titleBlock = ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
                        ),
                      ],
                    ),
                  );

                  final controls = _EntityWorkspaceControls(
                    sourceLabel: sourceLabel,
                    isLive: isLive,
                    isLoading: isLoading,
                    onRefresh: onRefresh,
                    primaryActionLabel: primaryActionLabel,
                    primaryActionIcon: primaryActionIcon,
                    onPrimaryAction: onPrimaryAction,
                  );

                  if (!controls.hasControls) {
                    return titleBlock;
                  }

                  if (constraints.maxWidth < _workspaceHeaderInlineMinWidth) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleBlock,
                        const SizedBox(height: 18),
                        controls,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: titleBlock),
                      const SizedBox(width: 22),
                      controls,
                    ],
                  );
                },
              ),
              if (searchController != null) ...[
                const SizedBox(height: 20),
                _EntitySearchField(
                  controller: searchController!,
                  hintText: data.searchHint,
                  accent: data.accent,
                  onSubmitSearch: onSubmitSearch,
                  onClearSearch: onClearSearch,
                  enabled: !isLoading,
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: data.searchHint,
                    icon: Icons.search_rounded,
                    color: _mutedColor,
                    background: const Color(0xFFF4EEE5),
                  ),
                  _Tag(
                    label: '${data.items.length} registros no recorte',
                    icon: Icons.dataset_outlined,
                    color: data.accent,
                    background: data.accent.withValues(alpha: 0.12),
                  ),
                  if (viewerProfile.isAuthenticated && readableNoteCount > 0)
                    _Tag(
                      label:
                          '$readableNoteCount tags visiveis para este perfil',
                      icon: Icons.lock_open_rounded,
                      color: _roseColor,
                      background: _roseColor.withValues(alpha: 0.12),
                    ),
                  if (viewerProfile.isAuthenticated &&
                      readableAttachmentCount > 0)
                    _Tag(
                      label:
                          '$readableAttachmentCount anexos visiveis para este perfil',
                      icon: Icons.attach_file_rounded,
                      color: _amberColor,
                      background: _amberColor.withValues(alpha: 0.12),
                    ),
                  if (viewerProfile.isAuthenticated &&
                      itemsWithReadableSensitiveContent > 0)
                    _Tag(
                      label:
                          '$itemsWithReadableSensitiveContent fichas com compartilhamento ativo',
                      icon: Icons.shield_outlined,
                      color: _slateColor,
                      background: _slateColor.withValues(alpha: 0.12),
                    ),
                  for (final filter in data.filters)
                    _Tag(
                      label: filter,
                      icon: Icons.tune_outlined,
                      color: data.accent,
                      background: data.accent.withValues(alpha: 0.12),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _lineColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primeiro passo real',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.productionHint,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final focus in data.integrationFocus)
                          _Tag(
                            label: focus,
                            icon: Icons.arrow_outward_rounded,
                            color: data.accent,
                            background: data.accent.withValues(alpha: 0.10),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _EntityRuntimeNotice(message: errorMessage!, onRetry: onRefresh),
        ],
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < _workspaceMasterDetailInlineMinWidth;
            if (selectedItem == null) {
              return const _Panel(child: _EntityEmptyState());
            }

            if (stacked) {
              return Column(
                children: [
                  _Panel(
                    child: _EntityListCard(
                      data: data,
                      selectedIndex: safeSelectedIndex,
                      onSelectItem: onSelectItem,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Panel(
                    child: _EntityDetailCard(
                      item: selectedItem,
                      viewerProfile: viewerProfile,
                    ),
                  ),
                ],
              );
            }

            final listWidth = (constraints.maxWidth * 0.48)
                .clamp(360.0, 620.0)
                .toDouble();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: listWidth,
                  child: _Panel(
                    child: _EntityListCard(
                      data: data,
                      selectedIndex: safeSelectedIndex,
                      onSelectItem: onSelectItem,
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: _Panel(
                    child: _EntityDetailCard(
                      item: selectedItem,
                      viewerProfile: viewerProfile,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EntityWorkspaceControls extends StatelessWidget {
  const _EntityWorkspaceControls({
    required this.sourceLabel,
    required this.isLive,
    required this.isLoading,
    required this.onRefresh,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.onPrimaryAction,
  });

  final String? sourceLabel;
  final bool isLive;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onPrimaryAction;

  bool get hasControls =>
      sourceLabel != null || onRefresh != null || onPrimaryAction != null;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (sourceLabel != null)
          _Tag(
            label: sourceLabel!,
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
        if (onRefresh != null)
          IconButton.outlined(
            tooltip: 'Sincronizar',
            onPressed: isLoading ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        if (onPrimaryAction != null && primaryActionLabel != null)
          FilledButton.icon(
            onPressed: isLoading ? null : onPrimaryAction,
            icon: Icon(primaryActionIcon ?? Icons.add_rounded),
            label: Text(primaryActionLabel!),
          ),
      ],
    );
  }
}

class _EntitySearchField extends StatelessWidget {
  const _EntitySearchField({
    required this.controller,
    required this.hintText,
    required this.accent,
    required this.enabled,
    this.onSubmitSearch,
    this.onClearSearch,
  });

  final TextEditingController controller;
  final String hintText;
  final Color accent;
  final bool enabled;
  final VoidCallback? onSubmitSearch;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    return _ContextSearchField(
      controller: controller,
      hintText: hintText,
      accent: accent,
      enabled: enabled,
      maxWidth: 620,
      onSubmitted: (_) => onSubmitSearch?.call(),
      onClear: onClearSearch,
      onSearch: onSubmitSearch,
    );
  }
}

class _EntityRuntimeNotice extends StatelessWidget {
  const _EntityRuntimeNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: _Panel(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: _amberColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
                    ),
                  ),
                ],
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Tentar novamente'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EntityEmptyState extends StatelessWidget {
  const _EntityEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nenhum registro encontrado',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'A pagina esta pronta, mas a API nao retornou itens para este recorte.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
      ],
    );
  }
}

class _EntityListCard extends StatelessWidget {
  const _EntityListCard({
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
        Text('Lista guiada', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          data.listHint,
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 18),
        for (final entry in data.items.indexed)
          _EntityListTile(
            item: entry.$2,
            selected: entry.$1 == selectedIndex,
            onTap: () => onSelectItem(entry.$1),
          ),
      ],
    );
  }
}

class _EntityDetailCard extends StatelessWidget {
  const _EntityDetailCard({required this.item, required this.viewerProfile});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Preview do detalhe', style: theme.textTheme.titleLarge),
            _Tag(
              label: item.publicId,
              icon: Icons.tag_outlined,
              color: _slateColor,
              background: _slateColor.withValues(alpha: 0.12),
            ),
            _Tag(
              label: item.status,
              icon: item.icon,
              color: item.color,
              background: item.color.withValues(alpha: 0.12),
            ),
            if (visibleAttachments.isNotEmpty)
              _Tag(
                label: '${visibleAttachments.length} anexos acessiveis',
                icon: Icons.attach_file_rounded,
                color: _amberColor,
                background: _amberColor.withValues(alpha: 0.12),
              ),
            if (visibleNotes.isNotEmpty)
              _Tag(
                label: '${visibleNotes.length} tags acessiveis',
                icon: Icons.lock_open_rounded,
                color: _roseColor,
                background: _roseColor.withValues(alpha: 0.12),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(item.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          item.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF7EF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _lineColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acesso sensivel em vigor',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                viewerProfile.description,
                style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: viewerProfile.label,
                    icon: viewerProfile.icon,
                    color: viewerProfile.color,
                    background: viewerProfile.color.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: viewerProfile.consultationSummary,
                    icon: viewerProfile.canViewSensitive
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    color: viewerProfile.canViewSensitive
                        ? _tealColor
                        : _roseColor,
                    background:
                        (viewerProfile.canViewSensitive
                                ? _tealColor
                                : _roseColor)
                            .withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: viewerProfile.managementSummary,
                    icon: viewerProfile.isAuthenticated
                        ? Icons.rule_folder_outlined
                        : Icons.outbox_outlined,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: 'visibilidade por autora/or, grupo ou pessoa',
                    icon: Icons.people_alt_outlined,
                    color: _amberColor,
                    background: _amberColor.withValues(alpha: 0.12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (!viewerProfile.isAuthenticated)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entrada publica', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Quem nao esta logado pode enviar observacoes curtas para esta ficha. Leitura, edicao e exclusao continuam restritas a sessao autenticada e ao compartilhamento definido pela autora ou pelo autor.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1E7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Por que esta tela existe',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  item.detailSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
                ),
              ],
            ),
          ),
        if (visibleAttachments.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Anexos e referencias', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final attachment in visibleAttachments)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                      Text(
                        attachment.title,
                        style: theme.textTheme.titleMedium,
                      ),
                      _Tag(
                        label: attachment.classification.label,
                        icon: attachment.classification.icon,
                        color: attachment.classification.color,
                        background: attachment.classification.color.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      _Tag(
                        label: attachment.publicId,
                        icon: Icons.tag_outlined,
                        color: _slateColor,
                        background: _slateColor.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    attachment.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _inkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    attachment.classification.description,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _mutedColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Tag(
                        label: attachment.status,
                        icon: Icons.inventory_2_outlined,
                        color: _amberColor,
                        background: _amberColor.withValues(alpha: 0.12),
                      ),
                      _Tag(
                        label: attachment.updatedAtLabel,
                        icon: Icons.update_outlined,
                        color: _slateColor,
                        background: _slateColor.withValues(alpha: 0.12),
                      ),
                      _Tag(
                        label: attachment.accessSummary(viewerProfile),
                        icon: Icons.visibility_outlined,
                        color: _tealColor,
                        background: _tealColor.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Compartilhamento', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _buildAccessPolicyTags(
                      attachment.accessPolicy,
                      attachment.accessPolicy.canViewerManage(viewerProfile),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 18),
        Text('Relacoes principais', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        for (final relation in item.relations)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _lineColor),
            ),
            child: Text(
              relation,
              style: theme.textTheme.bodyMedium?.copyWith(color: _inkColor),
            ),
          ),
        if (visibleNotes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Tags sensiveis e anotacoes protegidas',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Tag(
                      label: 'envio sem login permitido',
                      icon: Icons.outbox_outlined,
                      color: _slateColor,
                      background: _slateColor.withValues(alpha: 0.12),
                    ),
                    _Tag(
                      label: 'consulta exige autenticacao',
                      icon: Icons.lock_outline_rounded,
                      color: _roseColor,
                      background: _roseColor.withValues(alpha: 0.12),
                    ),
                    _Tag(
                      label: 'ate 350 caracteres por tag',
                      icon: Icons.short_text_rounded,
                      color: _amberColor,
                      background: _amberColor.withValues(alpha: 0.12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final note in visibleNotes)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                            _Tag(
                              label: note.label,
                              icon: note.classification.icon,
                              color: note.color,
                              background: note.color.withValues(alpha: 0.12),
                            ),
                            _Tag(
                              label: note.classification.label,
                              icon: Icons.label_important_outline_rounded,
                              color: _slateColor,
                              background: _slateColor.withValues(alpha: 0.10),
                            ),
                            _Tag(
                              label: 'ordem ${note.sortOrder}',
                              icon: Icons.swap_vert_rounded,
                              color: _amberColor,
                              background: _amberColor.withValues(alpha: 0.12),
                            ),
                            if (note.accessPolicy.canViewerManage(
                              viewerProfile,
                            ))
                              _Tag(
                                label: 'voce gerencia esta tag',
                                icon: Icons.settings_suggest_outlined,
                                color: _tealColor,
                                background: _tealColor.withValues(alpha: 0.12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          note.note,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _inkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _Tag(
                              label: note.accessSummary,
                              icon: Icons.lock_open_rounded,
                              color: _slateColor,
                              background: _slateColor.withValues(alpha: 0.12),
                            ),
                            if (note.accessPolicy.canViewerManage(
                              viewerProfile,
                            ))
                              _Tag(
                                label: 'cor e ordem editaveis',
                                icon: Icons.palette_outlined,
                                color: _amberColor,
                                background: _amberColor.withValues(alpha: 0.12),
                              ),
                            if (note.accessPolicy.canViewerManage(
                              viewerProfile,
                            ))
                              _Tag(
                                label: 'exclusao restrita a autoria',
                                icon: Icons.delete_sweep_outlined,
                                color: _roseColor,
                                background: _roseColor.withValues(alpha: 0.12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Compartilhamento',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _buildAccessPolicyTags(
                            note.accessPolicy,
                            note.accessPolicy.canViewerManage(viewerProfile),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildAccessPolicyTags(
    _ProtectedAccessPolicy policy,
    bool canManage,
  ) {
    final widgets = <Widget>[
      _Tag(
        label: 'autoria ${policy.owner.name}',
        icon: Icons.person_pin_circle_outlined,
        color: policy.owner.color,
        background: policy.owner.color.withValues(alpha: 0.12),
      ),
    ];

    if (policy.isOwnerOnly) {
      widgets.add(
        _Tag(
          label: 'somente autora/or',
          icon: Icons.key_outlined,
          color: _roseColor,
          background: _roseColor.withValues(alpha: 0.12),
        ),
      );
    } else {
      for (final group in policy.allowedGroups) {
        widgets.add(
          _Tag(
            label: group.label,
            icon: group.icon,
            color: group.color,
            background: group.color.withValues(alpha: 0.12),
          ),
        );
      }
      for (final person in policy.allowedPeople) {
        widgets.add(
          _Tag(
            label: person.name,
            icon: Icons.alternate_email_outlined,
            color: person.color,
            background: person.color.withValues(alpha: 0.12),
          ),
        );
      }
    }

    widgets.add(
      _Tag(
        label: policy.audienceSummary,
        icon: Icons.visibility_outlined,
        color: _slateColor,
        background: _slateColor.withValues(alpha: 0.12),
      ),
    );

    if (canManage) {
      widgets.add(
        _Tag(
          label: 'voce pode redefinir o acesso',
          icon: Icons.tune_outlined,
          color: _tealColor,
          background: _tealColor.withValues(alpha: 0.12),
        ),
      );
    }

    return widgets;
  }
}

class _EntityListTile extends StatelessWidget {
  const _EntityListTile({
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? item.color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? item.color : _lineColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(item.title, style: theme.textTheme.titleMedium),
                  _Tag(
                    label: item.status,
                    icon: item.icon,
                    color: item.color,
                    background: item.color.withValues(alpha: 0.12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
              const SizedBox(height: 10),
              Text(
                item.meta,
                style: theme.textTheme.labelMedium?.copyWith(color: item.color),
              ),
              const SizedBox(height: 6),
              Text(
                item.publicId,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntityWorkspaceData {
  const _EntityWorkspaceData({
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.listHint,
    required this.productionHint,
    required this.integrationFocus,
    required this.filters,
    required this.items,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String searchHint;
  final String listHint;
  final String productionHint;
  final List<String> integrationFocus;
  final List<String> filters;
  final List<_EntityItem> items;
  final Color accent;
}

class _EntityItem {
  const _EntityItem({
    required this.publicId,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.status,
    required this.icon,
    required this.color,
    required this.detailSummary,
    required this.relations,
    this.attachments = const [],
    this.sensitiveNotes = const [],
    this.personProfile,
    this.providerCompanySnapshot,
    this.clientCompanySnapshot,
    this.contractSnapshot,
    this.contractPositions = const [],
  });

  final String publicId;
  final String title;
  final String subtitle;
  final String meta;
  final String status;
  final IconData icon;
  final Color color;
  final String detailSummary;
  final List<String> relations;
  final List<_AttachmentRecord> attachments;
  final List<_SensitiveNoteTag> sensitiveNotes;
  final _PersonProfileData? personProfile;
  final _ProviderCompanyCrudSnapshot? providerCompanySnapshot;
  final _ClientCompanyCrudSnapshot? clientCompanySnapshot;
  final _ContractCrudSnapshot? contractSnapshot;
  final List<_ContractPositionRecord> contractPositions;
}
