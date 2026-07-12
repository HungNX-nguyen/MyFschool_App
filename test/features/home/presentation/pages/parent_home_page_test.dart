import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/home/presentation/pages/parent_home_page.dart';

void main() {
  testWidgets('renders the parent home content on a Pixel 6 Pro viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: ParentHomePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có học sinh liên kết'), findsOneWidget);
    expect(find.text('Các chức năng'), findsOneWidget);
    expect(find.text('Tin tức nhà trường'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
