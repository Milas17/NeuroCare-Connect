import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neurocare_connect/main.dart';

void main() {
  testWidgets('Dashboard -> Télémed : prise de RDV mémorisée', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(create: (_) => AppState(), child: MyApp()));
    await tester.pumpAndSettle();

    // Le tile Télémed existe
    expect(find.text('Télémed'), findsOneWidget);

    // Ouvrir la page Télémed
    await tester.tap(find.widgetWithText(ElevatedButton, 'Télémed'));
    await tester.pumpAndSettle();

    // On voit la liste des médecins
    expect(find.text('Médecins'), findsOneWidget);

    // Appuyer sur "Prendre RDV" (premier bouton trouvé)
    final rdvButton = find.widgetWithText(ElevatedButton, 'Prendre RDV').first;
    await tester.tap(rdvButton);
    await tester.pumpAndSettle();

    // La section "Mes RDV" apparaît et contient au moins un élément
    expect(find.text('Mes RDV'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}