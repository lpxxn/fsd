import 'dart:async';

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 6 章：Stream 进阶。
/// - 一个 StreamController 手动发事件
/// - 一个 async* 生成器 Stream
/// - 一个背压对比：快生产 + 慢消费 (asyncMap 串行)
class Chapter06Page extends StatefulWidget {
  const Chapter06Page({super.key});

  @override
  State<Chapter06Page> createState() => _Chapter06PageState();
}

class _Chapter06PageState extends State<Chapter06Page> {
  final List<String> _logs = [];
  final _ctrl = StreamController<int>.broadcast();
  int _counter = 0;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _ctrl.stream.listen((v) => _log('  控制器收到 $v'));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ctrl.close();
    super.dispose();
  }

  void _log(String s) => setState(() => _logs.add(s));

  void _push() {
    _counter++;
    _ctrl.add(_counter);
  }

  Stream<int> _fib() async* {
    var a = 0, b = 1;
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      yield a;
      final t = a + b;
      a = b;
      b = t;
    }
  }

  Future<void> _runFib() async {
    _log('--- async* 生成 fib ---');
    await for (final v in _fib()) {
      _log('  fib=$v');
    }
  }

  Future<void> _runBackpressure() async {
    _log('--- 背压: 快生产(50ms) + 慢消费(asyncMap 400ms) ---');
    final fast = Stream<int>.periodic(const Duration(milliseconds: 50), (i) => i).take(10);
    final sw = Stopwatch()..start();
    await for (final v in fast.asyncMap((e) async {
      await Future.delayed(const Duration(milliseconds: 400));
      return e;
    })) {
      _log('  处理完 $v  累计=${sw.elapsedMilliseconds}ms');
    }
    _log('  总耗时=${sw.elapsedMilliseconds}ms (asyncMap 串行, 每个 >= 400ms)');
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '06 · Stream 进阶',
      intro: '手动用 StreamController 发事件 / async* 生成器 / asyncMap 串行消费的背压演示。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _push,
                child: const Text('Controller 发一个事件'),
              ),
              ElevatedButton(
                onPressed: _runFib,
                child: const Text('async* 生成 fib'),
              ),
              ElevatedButton(
                onPressed: _runBackpressure,
                child: const Text('背压演示'),
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
