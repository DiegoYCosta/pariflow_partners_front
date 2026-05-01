part of '../../app/app.dart';

class _ContractsWorkspace extends StatelessWidget {
  const _ContractsWorkspace({
    required this.accessLevel,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessLevel accessLevel;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return _EntityWorkspace(
      data: _contractsWorkspaceData,
      accessLevel: accessLevel,
      selectedIndex: selectedIndex,
      onSelectItem: onSelectItem,
    );
  }
}
