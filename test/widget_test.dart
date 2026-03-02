import 'package:flutter_test/flutter_test.dart';
import 'package:ekonomi_ku/app.dart';

void main() {
  testWidgets('AppShell renders bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppShell());
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pinjaman'), findsOneWidget);
  });
}
