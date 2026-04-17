import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 2 章：watch / read / listen 对照 Demo。
/// 本页内置一个简单的 Notifier 让按钮能改状态，真正的 Notifier 章节在第 3 章。
class _Counter extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final _counterProvider = NotifierProvider<_Counter, int>(_Counter.new);

class Chapter02Page extends ConsumerStatefulWidget {
  const Chapter02Page({super.key});

  @override
  ConsumerState<Chapter02Page> createState() => _Chapter02PageState();
}

class _Chapter02PageState extends ConsumerState<Chapter02Page> {
  final List<String> _logs = [];
  int _buildCount = 0;

  void _log(String s) => setState(() => _logs.add(s));

  @override
  Widget build(BuildContext context) {
    _buildCount++;

    // listen：每次计数变动, 都会触发回调, 但当前 Widget 不因为 listen 而重建
    ref.listen<int>(_counterProvider, (prev, next) {
      _log('listen 收到: $prev -> $next');
    });

    // watch：订阅 + 重建
    final count = ref.watch(_counterProvider);

    return ChapterScaffold(
      title: '02 · ref 三件套',
      intro: 'watch = 读值并订阅, 触发 build 重建；'
          'read = 按钮里一次性读, 不订阅；'
          'listen = 订阅并执行副作用, 不重建本 Widget。',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoCell('计数 (watch)', '$count'),
                  _infoCell('build 次数', '$_buildCount'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(_counterProvider.notifier).increment();
                  _log('按钮: ref.read(.notifier).increment()');
                },
                child: const Text('read + increment (+1)'),
              ),
              ElevatedButton(
                onPressed: () {
                  final v = ref.read(_counterProvider);
                  _log('按钮只 read, 当前值=$v (不订阅)');
                },
                child: const Text('只 read 当前值'),
              ),
              OutlinedButton(
                onPressed: () => setState(_logs.clear),
                child: const Text('清空日志'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: LogPanel(lines: _logs)),
        ],
      ),
    );
  }

  Widget _infoCell(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
