import 'dart:js_interop';

@JS('window.open')
external JSObject? _openBrowserTab(String url, String target);

bool openStandaloneBrowserTab(String url) {
  return _openBrowserTab(url, '_blank') != null;
}
