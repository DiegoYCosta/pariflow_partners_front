part of '../../app/app.dart';

class _ContractsWorkspace extends StatelessWidget {
  const _ContractsWorkspace({
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return _EntityWorkspace(
      data: _contractsWorkspaceData,
      selectedIndex: selectedIndex,
      onSelectItem: onSelectItem,
    );
  }
}
