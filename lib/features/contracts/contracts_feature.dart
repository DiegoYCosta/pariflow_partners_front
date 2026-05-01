part of '../../app/app.dart';

class _ContractsWorkspace extends StatelessWidget {
  const _ContractsWorkspace({
    required this.viewerProfile,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  final _ViewerAccessProfile viewerProfile;
  final int selectedIndex;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return _EntityWorkspace(
      data: _contractsWorkspaceData,
      viewerProfile: viewerProfile,
      selectedIndex: selectedIndex,
      onSelectItem: onSelectItem,
    );
  }
}
