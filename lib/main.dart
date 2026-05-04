import 'package:flutter/material.dart';

import 'app/app.dart';

export 'app/app.dart' show PariFlowPartnersApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePariFlowFirebase();
  runApp(const PariFlowPartnersApp());
}
