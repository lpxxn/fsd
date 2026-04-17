import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';
import '06_riverpod/providers.dart';

/// 第 6 章 Demo: 用上面一组 @riverpod Provider。
class Chapter06Page extends ConsumerWidget {
  const Chapter06Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    final doubled = ref.watch(doubledProvider(5));
    final random = ref.watch(randomNumberProvider);
    final counter = ref.watch(counterProvider);
    final version = ref.watch(appVersionProvider);

    return ChapterScaffold(
      title: '06 · riverpod_generator',
      intro: '五种形态的 @riverpod 都在这里: 同步、family、Future、Notifier、keepAlive。'
          '打开 providers.g.dart 看它们被展开成了什么。',
      child: ListView(
        children: [
          _tile('greeting (同步)', greeting),
          _tile('doubled(5) (family)', '$doubled'),
          _tile(
            'randomNumber (Future)',
            random.when(
              data: (v) => '$v',
              loading: () => '…',
              error: (e, _) => 'ERR: $e',
            ),
          ),
          _tile('counter (Notifier)', '$counter'),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => ref.read(counterProvider.notifier).increment(),
                child: const Text('+1'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => ref.read(counterProvider.notifier).decrement(),
                child: const Text('-1'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => ref.read(counterProvider.notifier).reset(),
                child: const Text('reset'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(randomNumberProvider),
                child: const Text('刷新 random'),
              ),
            ],
          ),
          _tile('appVersion (keepAlive)', version),
        ],
      ),
    );
  }

  Widget _tile(String title, String value) {
    return ListTile(
      dense: true,
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontFamily: 'monospace')),
    );
  }
}
