import 'dart:async';

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 11 章：常见陷阱。集合几个可交互的演示。
class Chapter11Page extends StatefulWidget {
  const Chapter11Page({super.key});

  @override
  State<Chapter11Page> createState() => _Chapter11PageState();
}

class _Chapter11PageState extends State<Chapter11Page> {
  final List<String> _logs = [];
  bool _busy = false;

  void _log(String s) => setState(() => _logs.add(s));

  Future<int> _fetch(int i) =>
      Future.delayed(const Duration(milliseconds: 200), () => i);

  Future<void> _serial() async {
    setState(() => _busy = true);
    final sw = Stopwatch()..start();
    for (var i = 0; i < 5; i++) {
      await _fetch(i);
    }
    sw.stop();
    _log('串行 5x200ms  耗时=${sw.elapsedMilliseconds}ms');
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _parallel() async {
    setState(() => _busy = true);
    final sw = Stopwatch()..start();
    await Future.wait(List.generate(5, _fetch));
    sw.stop();
    _log('并行 Future.wait  耗时=${sw.elapsedMilliseconds}ms');
    if (mounted) setState(() => _busy = false);
  }

  void _forgetAwait() {
    _log('点击: 忘了 await 的陷阱');
    _fetch(42).then((v) => _log('  回调打印 $v'));
    _log('  函数已返回, 回调还没来');
  }

  Future<void> _contextAcrossAwait() async {
    _log('点击: 跨 await 后检查 mounted');
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    _log('  mounted=true, 可以安全 setState / 用 context');
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '11 · 常见陷阱',
      intro: '集合几个经典坑的演示：for+await 的串行化、忘了 await、跨 await 的 mounted 检查。'
          '完整清单看文档。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _busy ? null : _serial,
                child: const Text('for + await 串行'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _parallel,
                child: const Text('Future.wait 并行'),
              ),
              ElevatedButton(
                onPressed: _forgetAwait,
                child: const Text('忘了 await'),
              ),
              ElevatedButton(
                onPressed: _contextAcrossAwait,
                child: const Text('跨 await mounted'),
              ),
              OutlinedButton(
                onPressed: () => setState(_logs.clear),
                child: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: LogPanel(lines: _logs)),
        ],
      ),
    );
  }
}
