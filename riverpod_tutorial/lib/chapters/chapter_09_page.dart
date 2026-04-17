import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../common/chapter_scaffold.dart';

part 'chapter_09_page.g.dart';

/// 第 9 章 codegen：本文件即是对第 3 / 4 / 7 章手写 Provider 的 codegen 版本。
/// 构建前请运行：
///   dart run build_runner build --delete-conflicting-outputs

// ---- 对照第 3 章 CounterNotifier ----
@riverpod
class CounterCg extends _$CounterCg {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// ---- 对照第 4 章 quoteProvider (函数形式) ----
@riverpod
Future<String> quoteCg(Ref ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return 'codegen 版的 quote: 时间 ${DateTime.now().second}';
}

// ---- 对照第 7 章 weatherProvider.family (带多参数) ----
@riverpod
Future<String> weatherCg(Ref ref, {required String city, required String unit}) async {
  await Future.delayed(const Duration(milliseconds: 400));
  final t = (10 + city.hashCode % 20).abs();
  final v = unit == 'F' ? t * 9 / 5 + 32 : t.toDouble();
  return '$city: ${v.toStringAsFixed(1)} °$unit';
}

class Chapter09Page extends ConsumerWidget {
  const Chapter09Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterCgProvider);
    final quote = ref.watch(quoteCgProvider);
    final weather = ref.watch(weatherCgProvider(city: '北京', unit: 'C'));

    return ChapterScaffold(
      title: '09 · 代码生成 @riverpod',
      intro: '上面三块分别对照: 手写 NotifierProvider / 手写 FutureProvider / 手写 family。'
          '生成代码见 chapter_09_page.g.dart (build_runner 自动产出)。',
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('CounterCg (@riverpod class)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$counter', style: const TextStyle(fontSize: 28)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(counterCgProvider.notifier).decrement(),
                        child: const Text('-1'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(counterCgProvider.notifier).reset(),
                        child: const Text('重置'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(counterCgProvider.notifier).increment(),
                        child: const Text('+1'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('quoteCg (@riverpod 函数, Future)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  switch (quote) {
                    AsyncData(:final value) =>
                      Text(value, style: const TextStyle(fontSize: 16)),
                    AsyncError(:final error) =>
                      Text('$error', style: const TextStyle(color: Colors.red)),
                    _ => const CircularProgressIndicator(),
                  },
                  TextButton.icon(
                    onPressed: () => ref.invalidate(quoteCgProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('invalidate'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('weatherCg (@riverpod + 多参数 family)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('调用: ref.watch(weatherCgProvider(city: "北京", unit: "C"))'),
                  const SizedBox(height: 8),
                  switch (weather) {
                    AsyncData(:final value) =>
                      Text(value, style: const TextStyle(fontSize: 18)),
                    AsyncError(:final error) =>
                      Text('$error', style: const TextStyle(color: Colors.red)),
                    _ => const CircularProgressIndicator(),
                  },
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              '注: 首次打开前请运行  '
              'dart run build_runner build --delete-conflicting-outputs',
              style: TextStyle(color: Colors.black54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
