import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 8 章: autoDispose + onDispose/onCancel/onResume + keepAlive。
/// 本页使用全局 _lifecycleLog 把 Provider 生命周期事件输出到屏幕。

final List<String> _lifecycleLog = [];
final _logTickProvider = NotifierProvider<_LogTick, int>(_LogTick.new);

class _LogTick extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

void _logLine(WidgetRef ref, String s) {
  _lifecycleLog.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $s');
  if (_lifecycleLog.length > 50) _lifecycleLog.removeAt(0);
  ref.read(_logTickProvider.notifier).bump();
}

/// autoDispose 计时器 Provider
final ephemeralTimerProvider = StreamProvider.autoDispose<int>((ref) {
  _lifecycleLog.add('[build] ephemeralTimerProvider');
  final controller = StreamController<int>();
  var t = 0;
  final timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
    t++;
    controller.add(t);
  });
  ref.onCancel(() => _lifecycleLog.add('[onCancel] ephemeralTimerProvider'));
  ref.onResume(() => _lifecycleLog.add('[onResume] ephemeralTimerProvider'));
  ref.onDispose(() {
    _lifecycleLog.add('[onDispose] ephemeralTimerProvider (释放 Timer)');
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

/// keepAlive 版本：一次建立后不随 watcher 消失而销毁
final cachedRandomProvider = FutureProvider.autoDispose<int>((ref) async {
  _lifecycleLog.add('[build] cachedRandomProvider (贵的请求)');
  await Future.delayed(const Duration(milliseconds: 500));
  final val = DateTime.now().millisecondsSinceEpoch % 1000;

  ref.keepAlive();
  ref.onDispose(
      () => _lifecycleLog.add('[onDispose] cachedRandomProvider'));

  return val;
});

class Chapter08Page extends ConsumerStatefulWidget {
  const Chapter08Page({super.key});

  @override
  ConsumerState<Chapter08Page> createState() => _Chapter08PageState();
}

class _Chapter08PageState extends ConsumerState<Chapter08Page> {
  bool _showEphemeral = false;
  bool _showCached = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(_logTickProvider);
    return ChapterScaffold(
      title: '08 · autoDispose & 生命周期',
      intro: '切换两个开关, 观察日志里 build / onCancel / onResume / onDispose 的顺序。'
          'cachedRandomProvider 用 keepAlive, 即使关掉显示, 下次打开仍是同一个值。',
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('显示 ephemeralTimer (autoDispose, 无 keepAlive)'),
            value: _showEphemeral,
            onChanged: (v) {
              _logLine(ref, v ? '开关打开: 开始 watch ephemeral' : '开关关闭: 退订');
              setState(() => _showEphemeral = v);
            },
          ),
          if (_showEphemeral)
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _EphemeralView(),
              ),
            ),
          SwitchListTile(
            title: const Text('显示 cachedRandom (autoDispose + keepAlive)'),
            value: _showCached,
            onChanged: (v) {
              _logLine(ref, v ? '开关打开: 开始 watch cached' : '开关关闭: 退订 (但不销毁)');
              setState(() => _showCached = v);
            },
          ),
          if (_showCached)
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _CachedView(),
              ),
            ),
          const SizedBox(height: 8),
          Row(children: [
            TextButton.icon(
              onPressed: () {
                ref.invalidate(cachedRandomProvider);
                _logLine(ref, '外部 invalidate(cachedRandomProvider)');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('手动 invalidate cachedRandom'),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                _lifecycleLog.clear();
                ref.read(_logTickProvider.notifier).bump();
              },
              child: const Text('清空日志'),
            ),
          ]),
          Expanded(child: LogPanel(lines: _lifecycleLog, title: '生命周期事件')),
        ],
      ),
    );
  }
}

class _EphemeralView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(ephemeralTimerProvider);
    return Text(
      'ephemeralTimer tick = ${stream.value ?? '...'}',
      style: const TextStyle(fontSize: 16),
    );
  }
}

class _CachedView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(cachedRandomProvider);
    return switch (v) {
      AsyncData(:final value) => Text(
          'cachedRandom = $value (多次切换仍是它)',
          style: const TextStyle(fontSize: 16),
        ),
      _ => const Text('加载中...'),
    };
  }
}
