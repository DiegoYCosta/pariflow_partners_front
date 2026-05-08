import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pariflow_partners/app/app.dart';

void main() {
  testWidgets('shows auth unavailable screen without Firebase config', (
    tester,
  ) async {
    await tester.pumpWidget(const PariFlowPartnersApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Autenticacao indisponivel'), findsOneWidget);
    expect(
      find.text(
        'Este build exige Firebase configurado para acessar o sistema.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders the initial layout shell', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LayoutPreviewPage()));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Search people, companies...'), findsOneWidget);
    expect(find.text('Companies'), findsWidgets);
    expect(find.text('Clients'), findsWidgets);
    expect(find.text('Contracts'), findsWidgets);
    expect(find.text('Visual Network'), findsWidgets);
  });

  testWidgets('keeps the CRM home content inside a desktop viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1366, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: LayoutPreviewPage()));
    await tester.pump(const Duration(milliseconds: 250));

    final quote = find.text(
      'Clarity drives better decisions. Insight builds stronger partnerships.',
    );
    final sidebarProfile = find.text('Diego Costa').first;

    expect(quote, findsOneWidget);
    expect(tester.getBottomRight(quote).dy, lessThanOrEqualTo(900));
    expect(sidebarProfile, findsOneWidget);
    expect(tester.getBottomRight(sidebarProfile).dy, lessThanOrEqualTo(900));
  });
}
