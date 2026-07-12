import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/home/presentation/pages/teacher_home_page.dart';

void main() {
  testWidgets('renders the teacher home content on a Pixel 6 Pro viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: TeacherHomePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có lớp chủ nhiệm'), findsOneWidget);
    expect(find.text('Lớp CN'), findsOneWidget);
    expect(find.text('Nhập điểm'), findsOneWidget);
    expect(find.text('Lịch dạy'), findsOneWidget);
    expect(find.text('Các loại phí'), findsOneWidget);
    expect(find.text('Đơn từ'), findsOneWidget);
    expect(find.text('Gửi thông báo'), findsOneWidget);
    expect(find.text('Tin tức nhà trường'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(9));
    expect(tester.takeException(), isNull);
  });
}
