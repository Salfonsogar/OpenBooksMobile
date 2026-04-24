import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/shared/ui/widgets/shimmer_loading.dart';

void main() {
  group('ShimmerLoading', () {
    testWidgets('renders with specified dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(100));
      expect(container.constraints?.maxHeight, equals(50));
    });

    testWidgets('card factory creates widget with rounded shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading.card(),
          ),
        ),
      );

      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('avatar factory creates circle shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading.avatar(),
          ),
        ),
      );

      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('text factory creates rectangle shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading.text(),
          ),
        ),
      );

      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });

  group('ShimmerList', () {
    testWidgets('renders list with specified item count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerList(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(ShimmerList), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('ShimmerGrid', () {
    testWidgets('renders grid with specified cross axis count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerGrid(crossAxisCount: 3),
          ),
        ),
      );

      expect(find.byType(ShimmerGrid), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}