import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/home/presentation/pages/student_home_page.dart';

void main() {
  testWidgets('calls learning result action from the feature grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var learningResultTapCount = 0;
    var schoolEventTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StudentHomePage(
          onProfileTap: () {},
          onTimetableTap: () {},
          onLearningResultTap: () => learningResultTapCount++,
          onSchoolEventTap: () => schoolEventTapCount++,
        ),
      ),
    );

    await tester.tap(find.text('KQ Học tập'));

    expect(learningResultTapCount, 1);

    final schoolEventFeature = find.text('Sự kiện');
    await tester.ensureVisible(schoolEventFeature);
    await tester.tap(schoolEventFeature);

    expect(schoolEventTapCount, 1);
    expect(tester.takeException(), isNull);
  });
}
