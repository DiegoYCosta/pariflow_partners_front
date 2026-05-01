part of '../../app/app.dart';

class _EntityWorkspace extends StatelessWidget {
  const _EntityWorkspace({
    required this.data,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _EntityWorkspaceData data;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final selectedItem = data.items[selectedIndex];
    final protectedNoteCount = data.items.fold<int>(
      0,
      (total, item) => total + item.sensitiveNotes.length,
    );
    final itemsWithProtectedNotes = data.items
        .where((item) => item.sensitiveNotes.isNotEmpty)
        .length;

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                data.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: _mutedColor),
              ),
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
                  _Tag(
                    label: '$protectedNoteCount tags protegidas',
                    icon: Icons.lock_outline_rounded,
                    color: _roseColor,
                    background: _roseColor.withValues(alpha: 0.12),
                  ),
                  if (itemsWithProtectedNotes > 0)
                    _Tag(
                      label: '$itemsWithProtectedNotes fichas com memoria sensivel',
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
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1120;

            if (stacked) {
              return Column(
                children: [
                  _Panel(
                    child: _EntityListCard(
                      data: data,
                      selectedIndex: selectedIndex,
                      onSelectItem: onSelectItem,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Panel(child: _EntityDetailCard(item: selectedItem)),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _Panel(
                    child: _EntityListCard(
                      data: data,
                      selectedIndex: selectedIndex,
                      onSelectItem: onSelectItem,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 5,
                  child: _Panel(child: _EntityDetailCard(item: selectedItem)),
                ),
              ],
            );
          },
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
  const _EntityDetailCard({required this.item});

  final _EntityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderedNotes = [...item.sensitiveNotes]
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));

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
            if (orderedNotes.isNotEmpty)
              _Tag(
                label: '${orderedNotes.length} tags protegidas',
                icon: Icons.lock_outline_rounded,
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
        if (orderedNotes.isNotEmpty) ...[
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
                      label: 'envio sem login',
                      icon: Icons.outbox_outlined,
                      color: _slateColor,
                      background: _slateColor.withValues(alpha: 0.12),
                    ),
                    _Tag(
                      label: 'consulta exige sessao',
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
                for (final note in orderedNotes)
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
                        Text(
                          note.accessSummary,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _mutedColor,
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
    this.sensitiveNotes = const [],
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
  final List<_SensitiveNoteTag> sensitiveNotes;
}
