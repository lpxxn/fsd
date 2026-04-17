import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 1 章：最小的 Provider + ConsumerWidget + ref.watch。
final greetingProvider = Provider<String>((ref) => 'Hello, Riverpod!');

final timeProvider = Provider<String>((ref) {
  // 第一次被 watch 时跑一次，结果被缓存；本章演示中用 DateTime 验证缓存
  return DateTime.now().toIso8601String();
});

class Chapter01Page extends ConsumerWidget {
  const Chapter01Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    final time = ref.watch(timeProvider);
    return ChapterScaffold(
      title: '01 · 第一个 Provider',
      intro: 'Provider 是最简单的一种：给 ref 一个函数, 第一次 watch 跑一次, '
          '结果缓存；之后所有 watch 都拿同一个值。',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(greeting, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('timeProvider 首次计算时间 (证明被缓存)'),
                  const SizedBox(height: 8),
                  SelectableText(
                    time,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '不管你如何反复进出这个页面, 这个时间都不会变——'
                    '因为 ProviderScope 还在, 值一直被缓存着。',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
