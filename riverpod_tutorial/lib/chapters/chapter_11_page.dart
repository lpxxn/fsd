import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 11 章 Demo：把 ProviderObserver 的日志可视化。
/// 展示 add / update / dispose 事件, 印证 Element 依赖图模型。

class _LogSink extends Notifier<List<String>> {
  @override
  List<String> build() => const [];
  void add(String s) {
    final now = DateTime.now().toIso8601String().substring(11, 23);
    state = [...state, '[$now] $s'];
    if (state.length > 40) state = state.sublist(state.length - 40);
  }

  void clear() => state = const [];
}

final _logSinkProvider = NotifierProvider<_LogSink, List<String>>(_LogSink.new);

final class _DemoObserver extends ProviderObserver {
  _DemoObserver(this._logFn);
  final void Function(String) _logFn;

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    _logFn('add:    ${context.provider.runtimeType} = $value');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _logFn('update: ${context.provider.runtimeType}: $previousValue → $newValue');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    _logFn('dispose: ${context.provider.runtimeType}');
  }
}

// 演示用的 Provider 链: a -> b -> c
final cProvider = NotifierProvider<_CNotifier, int>(_CNotifier.new);
final bProvider = Provider<int>((ref) => ref.watch(cProvider) * 2);
final aProvider = Provider<int>((ref) => ref.watch(bProvider) + 100);

class _CNotifier extends Notifier<int> {
  @override
  int build() => 1;
  void bump() => state++;
}

class Chapter11Page extends StatefulWidget {
  const Chapter11Page({super.key});

  @override
  State<Chapter11Page> createState() => _Chapter11PageState();
}

class _Chapter11PageState extends State<Chapter11Page> {
  late final ProviderContainer _container;
  late final _DemoObserver _observer;

  @override
  void initState() {
    super.initState();
    _observer = _DemoObserver((s) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _container.read(_logSinkProvider.notifier).add(s);
      });
    });
    _container = ProviderContainer(observers: [_observer]);
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _container,
      child: const _InnerPage(),
    );
  }
}

class _InnerPage extends ConsumerWidget {
  const _InnerPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(aProvider);
    final b = ref.watch(bProvider);
    final c = ref.watch(cProvider);
    final logs = ref.watch(_logSinkProvider);

    return ChapterScaffold(
      title: '11 · 内部原理',
      intro: 'c -> b (c*2) -> a (b+100) 形成依赖链。'
          '点 "c bump" 观察 observer 日志里 update 的传播顺序。',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _cell('c', c),
                  const Icon(Icons.arrow_right_alt),
                  _cell('b (=c*2)', b),
                  const Icon(Icons.arrow_right_alt),
                  _cell('a (=b+100)', a),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => ref.read(cProvider.notifier).bump(),
                child: const Text('c bump +1'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(bProvider),
                child: const Text('invalidate b'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => ref.read(_logSinkProvider.notifier).clear(),
                child: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: LogPanel(lines: logs, title: 'ProviderObserver')),
        ],
      ),
    );
  }

  Widget _cell(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text('$value',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
