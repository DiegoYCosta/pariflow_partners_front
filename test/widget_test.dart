import 'package:flutter_test/flutter_test.dart';

import 'package:pariflow_partners/main.dart';

void main() {
  testWidgets('renders the initial layout shell', (tester) async {
    await tester.pumpWidget(const PariFlowPartnersApp());
    await tester.pumpAndSettle();

    expect(find.text('PariFlow Partners'), findsOneWidget);
    expect(find.text('O que voce deseja consultar hoje?'), findsOneWidget);
    expect(find.text('Leitura de rollout'), findsOneWidget);
  });
}
