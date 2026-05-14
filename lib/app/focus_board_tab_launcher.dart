import 'focus_board_tab_launcher_stub.dart'
    if (dart.library.html) 'focus_board_tab_launcher_web.dart'
    as platform;

enum FocusBoardWindowOpenStatus {
  opened,
  focusedExisting,
  blocked,
  unsupported,
}

class FocusBoardWindowOpenResult {
  const FocusBoardWindowOpenResult(this.status);

  final FocusBoardWindowOpenStatus status;

  bool get openedInBrowser =>
      status == FocusBoardWindowOpenStatus.opened ||
      status == FocusBoardWindowOpenStatus.focusedExisting;
}

FocusBoardWindowOpenResult openFocusBoardStandaloneWindow(Uri uri) {
  final status = platform.openStandaloneBrowserWindow(uri.toString());
  return FocusBoardWindowOpenResult(switch (status) {
    'opened' => FocusBoardWindowOpenStatus.opened,
    'focusedExisting' => FocusBoardWindowOpenStatus.focusedExisting,
    'blocked' => FocusBoardWindowOpenStatus.blocked,
    _ => FocusBoardWindowOpenStatus.unsupported,
  });
}

bool isFocusBoardStandaloneWindowOpen() {
  return platform.isStandaloneBrowserWindowOpen();
}

void closeFocusBoardStandaloneWindow() {
  platform.closeStandaloneBrowserWindow();
}

bool closeCurrentFocusBoardWindow() {
  return platform.closeCurrentBrowserWindow();
}

bool openExternalBrowserTab(Uri uri) {
  return platform.openExternalBrowserTab(uri.toString());
}

bool openExternalBrowserPopup(Uri uri) {
  return platform.openExternalBrowserPopup(uri.toString());
}
