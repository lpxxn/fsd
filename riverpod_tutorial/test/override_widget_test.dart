import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tutorial/chapters/chapter_10_page.dart';

void main() {
  testWidgets('override 成固定值后, UI 显示该值', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fetchMessageProvider.overrideWith((ref) async => 'override 成功!'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final v = ref.watch(fetchMessageProvider);
                return switch (v) {
                  AsyncData(:final value) => Text(value),
                  _ => const Text('loading...'),
                };
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('loading...'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('override 成功!'), findsOneWidget);
  });

  testWidgets('override 成立即 data 也能读到', (tester) async {
    // 演示 overrideWithValue 把 AsyncValue 直接置为 AsyncData
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fetchMessageProvider.overrideWith((ref) async => '立即返回'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final v = ref.watch(fetchMessageProvider);
                return switch (v) {
                  AsyncData(:final value) => Text(value),
                  _ => const Text('loading...'),
                };
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('立即返回'), findsOneWidget);
  });
}
