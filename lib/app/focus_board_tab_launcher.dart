import 'focus_board_tab_launcher_stub.dart'
    if (dart.library.html) 'focus_board_tab_launcher_web.dart';

bool openFocusBoardStandaloneTab(Uri uri) {
  return openStandaloneBrowserTab(uri.toString());
}
