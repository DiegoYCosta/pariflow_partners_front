import 'dart:js_interop';

const _focusBoardWindowTarget = 'pariflow_focus_board_window';

_FocusBoardBrowserWindow? _focusBoardWindow;

extension type _FocusBoardBrowserWindow(JSObject _) implements JSObject {
  external bool get closed;
  external void close();
  external void focus();
}

@JS('window.open')
external _FocusBoardBrowserWindow? _openBrowserWindow(
  String url,
  String target,
  String features,
);

@JS('window.close')
external void _closeCurrentWindow();

@JS('window.focus')
external void _focusCurrentWindow();

@JS('window.screenX')
external double get _windowScreenX;

@JS('window.screenY')
external double get _windowScreenY;

@JS('window.outerWidth')
external double get _windowOuterWidth;

@JS('window.screen.availWidth')
external double get _screenAvailWidth;

@JS('window.screen.availHeight')
external double get _screenAvailHeight;

String openStandaloneBrowserWindow(String url) {
  final existingWindow = _focusBoardWindow;
  if (existingWindow != null && !existingWindow.closed) {
    existingWindow.focus();
    return 'focusedExisting';
  }

  final openedWindow = _openBrowserWindow(
    url,
    _focusBoardWindowTarget,
    _focusBoardWindowFeatures(),
  );
  if (openedWindow == null) {
    _focusBoardWindow = null;
    return 'blocked';
  }

  _focusBoardWindow = openedWindow;
  openedWindow.focus();
  return 'opened';
}

bool isStandaloneBrowserWindowOpen() {
  final existingWindow = _focusBoardWindow;
  if (existingWindow == null) {
    return false;
  }
  if (existingWindow.closed) {
    _focusBoardWindow = null;
    return false;
  }
  return true;
}

void closeStandaloneBrowserWindow() {
  final existingWindow = _focusBoardWindow;
  if (existingWindow == null || existingWindow.closed) {
    _focusBoardWindow = null;
    return;
  }
  existingWindow.close();
  _focusBoardWindow = null;
}

bool closeCurrentBrowserWindow() {
  _focusCurrentWindow();
  _closeCurrentWindow();
  return true;
}

String _focusBoardWindowFeatures() {
  final width = _screenAvailWidth < 720 ? 640 : 780;
  final height = _screenAvailHeight < 720 ? 600 : 660;
  final left = (_windowScreenX + _windowOuterWidth - width - 32)
      .clamp(12, _screenAvailWidth - width - 12)
      .round();
  final top = (_windowScreenY + 48)
      .clamp(12, _screenAvailHeight - height - 12)
      .round();
  return 'popup=yes,width=$width,height=$height,left=$left,top=$top,'
      'resizable=yes,scrollbars=yes,status=no,toolbar=no,menubar=no,'
      'location=no';
}
