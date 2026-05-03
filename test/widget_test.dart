import 'package:flutter_test/flutter_test.dart';

import 'package:pariflow_partners/main.dart';

void main() {
  testWidgets('renders the initial layout shell', (tester) async {
    await tester.pumpWidget(const PariFlowPartnersApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Search people, companies...'), findsOneWidget);
    expect(find.text('Companies'), findsWidgets);
    expect(find.text('Clients'), findsWidgets);
    expect(find.text('Contracts'), findsWidgets);
    expect(find.text('Visual Network'), findsWidgets);
  });
}
