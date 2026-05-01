part of '../../app/app.dart';

class _CompaniesWorkspace extends StatelessWidget {
  const _CompaniesWorkspace({
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
      data: _companiesWorkspaceData,
      accessLevel: accessLevel,
      selectedIndex: selectedIndex,
      onSelectItem: onSelectItem,
    );
  }
}
