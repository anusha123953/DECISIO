
import 'package:flutter_test/flutter_test.dart';
import 'package:decisio/main.dart';

void main() {
  testWidgets('DECISIO launches successfully', (tester) async {
    await tester.pumpWidget(const DecisioApp());

    expect(find.text('DECISIO'), findsOneWidget);
    expect(find.text('Think clearly.'), findsOneWidget);
  });
}
