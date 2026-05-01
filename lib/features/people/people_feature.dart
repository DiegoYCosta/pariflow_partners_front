part of '../../app/app.dart';

class _PeopleWorkspace extends StatelessWidget {
  const _PeopleWorkspace({
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
      data: _peopleWorkspaceData,
      viewerProfile: viewerProfile,
      selectedIndex: selectedIndex,
      onSelectItem: onSelectItem,
    );
  }
}
