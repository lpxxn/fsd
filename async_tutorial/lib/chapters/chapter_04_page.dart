import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 4 章：并行组合。串行 vs Future.wait vs Future.any 耗时对比。
class Chapter04Page extends StatefulWidget {
  const Chapter04Page({super.key});

  @override
  State<Chapter04Page> createState() => _Chapter04PageState();
}

class _Chapter04PageState extends State<Chapter04Page> {
  final List<String> _logs = [];
  bool _busy = false;

  void _log(String s) => setState(() => _logs.add(s));

  Future<int> _fakeFetch(String name, int ms) =>
      Future.delayed(Duration(milliseconds: ms), () => ms);

  Future<void> _runSerial() async {
    setState(() => _busy = true);
    _log('--- 串行: 每个 600ms ---');
    final sw = Stopwatch()..start();
    final a = await _fakeFetch('A', 600);
    final b = await _fakeFetch('B', 600);
    final c = await _fakeFetch('C', 600);
    sw.stop();
    _log('结果=[$a,$b,$c], 耗时=${sw.elapsedMilliseconds}ms');
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _runParallel() async {
    setState(() => _busy = true);
    _log('--- 并行 Future.wait ---');
    final sw = Stopwatch()..start();
    final list = await Future.wait([
      _fakeFetch('A', 600),
      _fakeFetch('B', 600),
      _fakeFetch('C', 600),
    ]);
    sw.stop();
    _log('结果=$list, 耗时=${sw.elapsedMilliseconds}ms');
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _runAny() async {
    setState(() => _busy = true);
    _log('--- Future.any 最快的那个 ---');
    final sw = Stopwatch()..start();
    final first = await Future.any([
      _fakeFetch('慢', 900),
      _fakeFetch('中', 500),
      _fakeFetch('快', 200),
    ]);
    sw.stop();
    _log('最快=$first, 耗时=${sw.elapsedMilliseconds}ms (其它还在后台跑但结果被丢弃)');
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '04 · 并行组合',
      intro: '对比串行 (await 一个个等) vs 并行 Future.wait (同时等)，'
          '并展示 Future.any 取最快的用法。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _busy ? null : _runSerial,
                child: const Text('串行 3x600ms'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _runParallel,
                child: const Text('并行 Future.wait'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _runAny,
                child: const Text('Future.any 取最快'),
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
