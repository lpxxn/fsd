import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 4 章：FutureProvider + AsyncValue。
final _rnd = Random();

final quoteProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  if (_rnd.nextInt(10) < 2) {
    throw Exception('网络抽风 (20% 概率)');
  }
  const quotes = [
    '简单好过复杂。',
    '过早优化是万恶之源。',
    'Talk is cheap, show me the code.',
    '能响应就不要轮询。',
  ];
  return quotes[_rnd.nextInt(quotes.length)];
});

class Chapter04Page extends ConsumerWidget {
  const Chapter04Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteProvider);

    return ChapterScaffold(
      title: '04 · FutureProvider & AsyncValue',
      intro: 'FutureProvider 把一个 Future 自动映射成 AsyncValue 的三态 '
          '(loading/data/error)。这里用 Dart 3 的 switch 模式匹配展示。',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: switch (quote) {
                  AsyncData(:final value) => Column(
                      children: [
                        const Icon(Icons.format_quote, size: 40, color: Colors.teal),
                        const SizedBox(height: 8),
                        Text(
                          value,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  AsyncError(:final error) => Column(
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          '错误: $error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  _ => const Column(
                      children: [
                        SizedBox(
                          width: 40, height: 40,
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(height: 8),
                        Text('加载中...'),
                      ],
                    ),
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(quoteProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('invalidate 重新请求'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final v = await ref.refresh(quoteProvider.future);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('refresh 拿到: $v')),
                    );
                  }
                },
                child: const Text('refresh 并 await'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '状态信息: isLoading=${quote.isLoading}, '
                'hasValue=${quote.hasValue}, hasError=${quote.hasError}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
