import 'package:bretonnier_carole/main.dart';
import 'package:flutter_test/flutter_test.dart';

Future<OperationsStore> pumpOperationsApp(WidgetTester tester) async {
  final store = OperationsStore();
  store.load();
  await tester.pumpWidget(BretonnierApp(store: store));
  await tester.pump(const Duration(milliseconds: 300));
  return store;
}

void main() {
  testWidgets('shows the operations dashboard', (WidgetTester tester) async {
    await pumpOperationsApp(tester);

    expect(find.text('BRETONNIER CAROLE'), findsOneWidget);
    expect(find.text('Daily operations snapshot'), findsOneWidget);
    expect(find.text('Open leads'), findsOneWidget);
    expect(find.text('Focus queue'), findsOneWidget);
  });

  testWidgets('creates a lead from the lead board', (
    WidgetTester tester,
  ) async {
    final store = await pumpOperationsApp(tester);

    await tester.tap(find.text('Leads'));
    await tester.pump(const Duration(milliseconds: 300));
    store.addLead(
      contactName: 'Aline',
      company: 'Nova Ops',
      need: 'Shift review',
      nextAction: 'Book Friday review',
      stage: LeadStage.newLead,
      priority: Priority.high,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Nova Ops'), findsOneWidget);
    expect(find.text('Book Friday review'), findsOneWidget);
  });

  testWidgets('opens local privacy settings', (WidgetTester tester) async {
    await pumpOperationsApp(tester);

    await tester.tap(find.byTooltip('Settings and privacy'));
    await tester.pumpAndSettle();

    expect(find.text('Settings and privacy'), findsOneWidget);
    expect(find.text('Local privacy'), findsOneWidget);
    expect(find.text(kSupportEmail), findsOneWidget);
  });
}
