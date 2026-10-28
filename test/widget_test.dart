import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sport6h50/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi', null);
  });

  testWidgets('SportBookingApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SportBookingApp());
    expect(find.byType(SportBookingApp), findsOneWidget);
  });
}
