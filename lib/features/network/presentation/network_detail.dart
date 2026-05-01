part of '../../../app/app.dart';

class _NetworkDetailCard extends StatelessWidget {
  const _NetworkDetailCard({
    required this.node,
    required this.visibleNodes,
    required this.selectedNodeLabel,
    required this.isPreview,
  });

  final _GraphNode node;
  final List<_GraphNode> visibleNodes;
  final String selectedNodeLabel;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final connections = _connectionDetailsForNode(node.id, visibleNodes);
    final theme = Theme.of(context);
    final groupedConnections = {
      for (final type in _GraphEdgeType.values)
        type: connections
            .where((connection) => connection.edge.type == type)
            .toList(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Leitura da teia', style: theme.textTheme.titleLarge),
            _Tag(
              label: node.kindLabel,
              icon: node.icon,
              color: node.color,
              background: node.color.withValues(alpha: 0.12),
            ),
            _Tag(
              label: isPreview
                  ? 'pre-visualizacao temporaria'
                  : 'selecionado fixo',
              icon: isPreview
                  ? Icons.mouse_outlined
                  : Icons.check_circle_outline_rounded,
              color: _slateColor,
              background: _slateColor.withValues(alpha: 0.12),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (isPreview) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leitura temporaria por hover',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Este painel esta lendo ${node.label}. Ao sair do hover, ele volta para $selectedNodeLabel.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        _NetworkDetailSectionCard(
          title: 'Resumo do no',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(node.label, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                node.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: _mutedColor),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _NetworkDetailFact(
                    label: 'Estado',
                    value: node.status,
                    icon: _statusIconForNode(node),
                    color: node.color,
                  ),
                  _NetworkDetailFact(
                    label: 'Tipo',
                    value: node.kindLabel,
                    icon: node.icon,
                    color: node.color,
                  ),
                  _NetworkDetailFact(
                    label: 'Relacoes',
                    value: '${connections.length} visiveis',
                    icon: Icons.route_outlined,
                    color: _slateColor,
                  ),
                  _NetworkDetailFact(
                    label: isPreview ? 'Retorna para' : 'Leitura fixa',
                    value: isPreview ? selectedNodeLabel : node.label,
                    icon: isPreview
                        ? Icons.undo_rounded
                        : Icons.check_circle_outline_rounded,
                    color: _slateColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (node.sector != null)
                    _Tag(
                      label: node.sector!,
                      icon: Icons.layers_outlined,
                      color: _amberColor,
                      background: _amberColor.withValues(alpha: 0.12),
                    ),
                  if (node.jobTitle != null)
                    _Tag(
                      label: node.jobTitle!,
                      icon: Icons.work_outline_rounded,
                      color: _slateColor,
                      background: _slateColor.withValues(alpha: 0.12),
                    ),
                  if (node.tenureBand != null)
                    _Tag(
                      label: node.tenureBand!,
                      icon: Icons.timelapse_outlined,
                      color: _tealColor,
                      background: _tealColor.withValues(alpha: 0.12),
                    ),
                  if (node.hasWarnings)
                    _Tag(
                      label: 'com advertencias',
                      icon: Icons.warning_amber_rounded,
                      color: _roseColor,
                      background: _roseColor.withValues(alpha: 0.12),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _NetworkDetailSectionCard(
          title: 'Leitura imediata',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final bullet in node.highlights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: node.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          bullet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _inkColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _NetworkDetailSectionCard(
          title: 'Relacionamentos visiveis',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: '${connections.length} relacoes',
                    icon: Icons.route_outlined,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
                  _Tag(
                    label: 'somente leitura',
                    icon: Icons.remove_red_eye_outlined,
                    color: _slateColor,
                    background: _slateColor.withValues(alpha: 0.12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (connections.isEmpty)
                Text(
                  'Nenhuma relacao ficou visivel neste recorte.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedColor,
                  ),
                )
              else
                for (final type in _GraphEdgeType.values)
                  if (groupedConnections[type]!.isNotEmpty) ...[
                    Text(type.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final connection in groupedConnections[type]!)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _lineColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              connection.node.icon,
                              color: connection.node.color,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        connection.node.label,
                                        style: theme.textTheme.labelLarge,
                                      ),
                                      _CompactRelationPill(
                                        type: connection.edge.type,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    connection.edge.detail,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: _mutedColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
            ],
          ),
        ),
      ],
    );
  }
}

