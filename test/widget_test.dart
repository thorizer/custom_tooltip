import 'package:custom_tooltip/custom_tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomTooltip Widget Tests', () {
    testWidgets('CustomTooltip displays child widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomTooltip(
            tooltip: Text('Tooltip content'),
            child: Text('Hover me'),
          ),
        ),
      );

      expect(find.text('Hover me'), findsOneWidget);
      expect(find.text('Tooltip content'), findsNothing);
    });

    testWidgets('CustomTooltip shows tooltip on hover (desktop)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomTooltip(
            tooltip: Text('Tooltip content'),
            hoverShowDelay: Duration(milliseconds: 100),
            child: Text('Hover me'),
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.text('Hover me')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Tooltip content'), findsOneWidget);
    });

    testWidgets('CustomTooltip shows tooltip on tap (mobile)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomTooltip(
            tooltip: Text('Tooltip content'),
            child: Text('Tap me'),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      await tester.pump(
          const Duration(milliseconds: 200)); // Add a delay for the animation

      expect(find.text('Tooltip content'), findsOneWidget);
    });

    testWidgets('CustomTooltip hides tooltip when tapped outside',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              const CustomTooltip(
                tooltip: Text('Tooltip content'),
                child: Text('Tap me'),
              ),
              Positioned(
                right: 0,
                child: SizedBox(
                    width: 50, height: 50, child: Container(color: Colors.red)),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      await tester.pump(
          const Duration(milliseconds: 200)); // Add a delay for the animation
      expect(find.text('Tooltip content'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10)); // Tap outside the tooltip
      await tester.pump();
      await tester.pump(
          const Duration(milliseconds: 200)); // Add a delay for the animation
      expect(find.text('Tooltip content'), findsNothing);
    });

    testWidgets('CustomTooltip applies custom style',
        (WidgetTester tester) async {
      const customColor = Color(0xFF00FF00);
      const customTextStyle = TextStyle(color: Colors.red, fontSize: 20);

      await tester.pumpWidget(
        const MaterialApp(
          home: CustomTooltip(
            tooltip: Text('Styled tooltip'),
            backgroundColor: customColor,
            borderRadius: 10,
            textStyle: customTextStyle,
            child: Text('Tap me'),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      await tester.pump(
          const Duration(milliseconds: 200)); // Add a delay for the animation

      final tooltipFinder = find.byType(Material).last;
      final material = tester.widget<Material>(tooltipFinder);

      expect(material.color, equals(Colors.transparent));
      expect(material.borderRadius, equals(BorderRadius.circular(10)));

      final container = tester.widget<Container>(find
          .descendant(
            of: tooltipFinder,
            matching: find.byType(Container),
          )
          .last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));

      final tooltipText = tester.widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Styled tooltip'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );
      expect(tooltipText.style, equals(customTextStyle));
    });

    testWidgets('CustomTooltip respects tooltipWidth and tooltipHeight',
        (WidgetTester tester) async {
      const tooltipWidth = 200.0;
      const tooltipHeight = 100.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: CustomTooltip(
            tooltip: Text('Sized tooltip'),
            tooltipWidth: tooltipWidth,
            tooltipHeight: tooltipHeight,
            child: Text('Tap me'),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      await tester.pump(
          const Duration(milliseconds: 200)); // Add a delay for the animation

      final tooltipFinder = find.byType(Material).last;
      final container = tester.widget<Container>(find
          .descendant(
            of: tooltipFinder,
            matching: find.byType(Container),
          )
          .last);

      expect(container.constraints?.maxWidth, equals(tooltipWidth));
      expect(container.constraints?.maxHeight, equals(tooltipHeight));
    });

    testWidgets('CustomTooltip animation test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomTooltip(
            tooltip: Text('Animated tooltip'),
            showDuration: Duration(milliseconds: 300),
            hideDuration: Duration(milliseconds: 200),
            child: Text('Tap me'),
          ),
        ),
      );

      // Show the tooltip
      await tester.tap(find.text('Tap me'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Animated tooltip'), findsOneWidget);

      final fadeTransition = tester.widget<FadeTransition>(
        find.ancestor(
          of: find.text('Animated tooltip'),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(fadeTransition.opacity.value, greaterThan(0));
      expect(fadeTransition.opacity.value, lessThan(1));

      // Complete the show animation
      await tester.pump(const Duration(milliseconds: 150));
      expect(fadeTransition.opacity.value, equals(1));

      // Start hiding the tooltip
      await tester.tapAt(const Offset(10, 10)); // Tap outside to dismiss
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check that the tooltip is still visible but fading out
      expect(find.text('Animated tooltip'), findsOneWidget);
      expect(fadeTransition.opacity.value, lessThan(1));
      expect(fadeTransition.opacity.value, greaterThan(0));

      // Complete the hide animation
      await tester.pump(const Duration(milliseconds: 100));

      // The tooltip might still be in the widget tree, but should be fully transparent
      final fadeTransitionAfterHide = tester.widget<FadeTransition>(
        find.ancestor(
          of: find.text('Animated tooltip'),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(fadeTransitionAfterHide.opacity.value, equals(0));
    });
  });
}
