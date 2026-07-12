import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/app.dart';

void main() {
  testWidgets('App opens the login screen', (tester) async {
    await tester.pumpWidget(const MyFschoolApp());

    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
