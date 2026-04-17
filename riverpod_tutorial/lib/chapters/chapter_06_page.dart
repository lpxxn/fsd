import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 6 章：StreamProvider + StreamNotifier。

// 每秒发一个递增整数
final tickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});

// 一个可暂停的秒表 StreamNotifier
class StopwatchNotifier extends StreamNotifier<int> {
  Timer? _timer;
  int _ms = 0;
  bool _paused = true;
  late StreamController<int> _controller;

  @override
  Stream<int> build() {
    _controller = StreamController<int>.broadcast();
    ref.onDispose(() {
      _timer?.cancel();
      _controller.close();
    });
    return _controller.stream;
  }

  void start() {
    if (!_paused) return;
    _paused = false;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _ms += 100;
      _controller.add(_ms);
    });
  }

  void pause() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _paused = true;
    _ms = 0;
    _controller.add(0);
  }
}

final stopwatchProvider =
    StreamNotifierProvider<StopwatchNotifier, int>(StopwatchNotifier.new);

class Chapter06Page extends ConsumerWidget {
  const Chapter06Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tick = ref.watch(tickProvider);
    final sw = ref.watch(stopwatchProvider);

    return ChapterScaffold(
      title: '06 · StreamProvider',
      intro: 'StreamProvider 把 Stream 映射为 AsyncValue。'
          'StreamNotifier 对应可变版本, 支持初始化订阅 + 方法式修改。',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('每秒 tick (StreamProvider)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    tick.value?.toString() ?? '...',
                    style: const TextStyle(fontSize: 32),
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
                  const Text('秒表 (StreamNotifier + StreamController)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${((sw.value ?? 0) / 1000).toStringAsFixed(1)} s',
                    style: const TextStyle(fontSize: 32, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(stopwatchProvider.notifier).start(),
                        child: const Text('开始'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(stopwatchProvider.notifier).pause(),
                        child: const Text('暂停'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(stopwatchProvider.notifier).reset(),
                        child: const Text('重置'),
                      ),
                    ],
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
