import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 10 章 Demo：测试与 override 的"可视化"演示。
/// 页面内用 ProviderScope(overrides: [...]) 把 fetchMessageProvider
/// 换成一个假的实现，让你直观看到 "同一个 Provider 在不同 Scope 下返回不同值"。

final fetchMessageProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return '真实实现: 从后端拿到的消息';
});

class Chapter10Page extends StatelessWidget {
  const Chapter10Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '10 · 测试 & override',
      intro: '同一个 fetchMessageProvider, 在两个 ProviderScope 下被不同实现覆盖。'
          '这就是单测/Widget 测试 override 的核心机制。',
      child: Column(
        children: [
          // 不 override —— 走默认实现
          const _Scope('默认 Scope (真实实现)'),
          const SizedBox(height: 12),
          // Override 成固定值
          ProviderScope(
            overrides: [
              fetchMessageProvider.overrideWith((ref) async => '假实现 A: mock 成功响应'),
            ],
            child: const _Scope('Scope A: override 成功'),
          ),
          const SizedBox(height: 12),
          // Override 成抛错
          ProviderScope(
            overrides: [
              fetchMessageProvider.overrideWith(
                (ref) async => throw Exception('假实现 B: 模拟网络错误'),
              ),
            ],
            child: const _Scope('Scope B: override 抛错'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              '在测试里:\n'
              '  ProviderContainer(overrides: [...]) —— 无 Widget 的单测\n'
              '  ProviderScope(overrides: [...])    —— Widget 测试',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Scope extends ConsumerWidget {
  const _Scope(this.label);
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msg = ref.watch(fetchMessageProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 2,
              child: switch (msg) {
                AsyncData(:final value) =>
                  Text(value, style: const TextStyle(color: Colors.green)),
                AsyncError(:final error) => Text('$error',
                    style: const TextStyle(color: Colors.red)),
                _ => const Text('加载中...'),
              },
            ),
          ],
        ),
      ),
    );
  }
}
