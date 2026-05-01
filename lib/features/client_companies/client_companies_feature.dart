part of '../../app/app.dart';

class _ClientCompaniesWorkspace extends StatelessWidget {
  const _ClientCompaniesWorkspace({
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
      data: _clientCompaniesWorkspaceData,
      viewerProfile: viewerProfile,
      selectedIndex: selectedIndex,
      onSelectItem: onSelectItem,
    );
  }
}
