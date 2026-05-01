import 'package:flutter_test/flutter_test.dart';

import 'package:pariflow_partners/main.dart';

void main() {
  testWidgets('renders the initial layout shell', (tester) async {
    await tester.pumpWidget(const PariFlowPartnersApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Empresas'), findsWidgets);
    expect(find.text('Clientes'), findsWidgets);
    expect(find.text('Contratos'), findsWidgets);
    expect(find.text('Teia Visual'), findsOneWidget);
  });
}
