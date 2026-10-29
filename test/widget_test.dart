// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:libro_de_tareas/main.dart';

void main() {
  testWidgets('muestra la pantalla principal', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LibroDeTareasApp()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Libro de Tareas'), findsOneWidget);
  });
}
