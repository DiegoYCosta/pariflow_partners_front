import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static bool get isConfiguredForCurrentPlatform {
    return kIsWeb &&
        web.apiKey.isNotEmpty &&
        (web.authDomain ?? '').isNotEmpty &&
        web.projectId.isNotEmpty &&
        web.appId.isNotEmpty;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'Firebase ainda nao foi configurado para esta plataforma.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'PARIFLOW_FIREBASE_API_KEY',
      defaultValue: '',
    ),
    authDomain: String.fromEnvironment(
      'PARIFLOW_FIREBASE_AUTH_DOMAIN',
      defaultValue: '',
    ),
    projectId: String.fromEnvironment(
      'PARIFLOW_FIREBASE_PROJECT_ID',
      defaultValue: '',
    ),
    storageBucket: String.fromEnvironment(
      'PARIFLOW_FIREBASE_STORAGE_BUCKET',
      defaultValue: '',
    ),
    messagingSenderId: String.fromEnvironment(
      'PARIFLOW_FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    appId: String.fromEnvironment('PARIFLOW_FIREBASE_APP_ID', defaultValue: ''),
    measurementId: String.fromEnvironment(
      'PARIFLOW_FIREBASE_MEASUREMENT_ID',
      defaultValue: '',
    ),
  );
}
