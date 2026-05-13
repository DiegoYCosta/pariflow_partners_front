part of '../../app/app.dart';

class _EntityCrudActionsPanel extends StatelessWidget {
  const _EntityCrudActionsPanel({
    required this.item,
    required this.title,
    required this.summary,
    required this.editLabel,
    required this.removeLabel,
    required this.isLoading,
    required this.onEdit,
    this.onEditVisualIdentity,
    required this.onRemove,
  });

  final _EntityItem? item;
  final String title;
  final String summary;
  final String editLabel;
  final String removeLabel;
  final bool isLoading;
  final VoidCallback? onEdit;
  final VoidCallback? onEditVisualIdentity;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: const EdgeInsets.all(22),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    if (item != null)
                      _Tag(
                        label: item!.publicId,
                        icon: Icons.tag_outlined,
                        color: _slateColor,
                        background: _slateColor.withValues(alpha: 0.12),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item == null ? 'Selecione um registro para editar.' : summary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedColor,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: isLoading ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(editLabel),
              ),
              if (onEditVisualIdentity != null)
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onEditVisualIdentity,
                  icon: const Icon(Icons.palette_outlined),
                  label: const Text('Visual'),
                ),
              OutlinedButton.icon(
                onPressed: isLoading ? null : onRemove,
                icon: const Icon(Icons.archive_outlined),
                label: Text(removeLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirmEntityAction({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

void _showEntityUnavailableAction(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Acao disponivel apenas com dados reais da API.'),
    ),
  );
}
