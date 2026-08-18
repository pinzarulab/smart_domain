import 'package:flutter_test/flutter_test.dart';
import 'package:smart_domain_example/main.dart';

void main() {
  testWidgets('runs successful lookup scenario', (tester) async {
    await tester.pumpWidget(const SmartDomainExampleApp());

    expect(find.text('smart_domain'), findsOneWidget);
    expect(find.text('Choose a scenario below.'), findsOneWidget);

    await tester.tap(find.text('Look up user'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ada Lovelace'), findsWidgets);
  });
}
