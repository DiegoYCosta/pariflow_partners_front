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

  testWidgets('keeps auth unavailable screen inside a desktop viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1366, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PariFlowPartnersApp());
    await tester.pump(const Duration(milliseconds: 250));

    final title = find.text('Autenticacao indisponivel');
    final message = find.text(
      'Este build exige Firebase configurado para acessar o sistema.',
    );

    expect(title, findsOneWidget);
    expect(tester.getBottomRight(title).dy, lessThanOrEqualTo(900));
    expect(message, findsOneWidget);
    expect(tester.getBottomRight(message).dy, lessThanOrEqualTo(900));
  });
}
