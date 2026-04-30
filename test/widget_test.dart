import 'package:flutter_test/flutter_test.dart';

import 'package:pariflow_partners/main.dart';

void main() {
  testWidgets('renders the initial layout shell', (tester) async {
    await tester.pumpWidget(const PariFlowPartnersApp());

    expect(find.text('PariFlow Partners'), findsOneWidget);
    expect(find.text('Escolha por onde comecar.'), findsOneWidget);
    expect(find.text('Ver previa da teia'), findsOneWidget);
  });
}
