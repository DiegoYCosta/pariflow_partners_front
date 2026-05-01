part of '../../app/app.dart';

class _CompaniesWorkspace extends StatelessWidget {
  const _CompaniesWorkspace({
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
      data: _companiesWorkspaceData,
      viewerProfile: viewerProfile,
      selectedIndex: selectedIndex,
      onSelectItem: onSelectItem,
    );
  }
}
