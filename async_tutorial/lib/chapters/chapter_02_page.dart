import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 2 章：Future 基础。演示 .then / .catchError / .whenComplete 的触发顺序。
class Chapter02Page extends StatefulWidget {
  const Chapter02Page({super.key});

  @override
  State<Chapter02Page> createState() => _Chapter02PageState();
}

class _Chapter02PageState extends State<Chapter02Page> {
  final List<String> _logs = [];

  void _log(String s) {
    setState(() => _logs.add('${_ts()}  $s'));
  }

  String _ts() {
    final now = DateTime.now();
    return '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  Future<int> _fetchNumber({bool fail = false}) {
    return Future.delayed(const Duration(milliseconds: 800), () {
      if (fail) throw Exception('服务器挂了');
      return 42;
    });
  }

  void _runHappyPath() {
    _log('--- 点击: 成功链路 ---');
    _fetchNumber()
        .then((v) => _log('.then  拿到 $v'))
        .catchError((e, st) => _log('.catchError  $e'))
        .whenComplete(() => _log('.whenComplete  收尾'));
    _log('同步代码先跑完 (你应该先看到这一行)');
  }

  void _runErrorPath() {
    _log('--- 点击: 失败链路 ---');
    _fetchNumber(fail: true)
        .then((v) => _log('.then  拿到 $v   ← 不该打印'))
        .catchError((e, st) => _log('.catchError  $e'))
        .whenComplete(() => _log('.whenComplete  收尾'));
  }

  void _runChained() {
    _log('--- 点击: 链式摊平 ---');
    Future.value(1)
        .then((v) {
          _log('第一步 v=$v, 返回 Future<int>');
          return Future.delayed(const Duration(milliseconds: 300), () => v + 10);
        })
        .then((v) => _log('第二步 v=$v  (应为 11, 是 int 不是 Future)'));
  }

  void _clear() => setState(_logs.clear);

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '02 · Future 基础',
      intro: '点下面的按钮，看日志里回调的触发顺序。'
          '重点：同步代码会先跑完，之后事件循环才处理 Future 回调。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _runHappyPath,
                child: const Text('成功链路'),
              ),
              ElevatedButton(
                onPressed: _runErrorPath,
                child: const Text('失败链路'),
              ),
              ElevatedButton(
                onPressed: _runChained,
                child: const Text('链式摊平'),
              ),
              OutlinedButton(onPressed: _clear, child: const Text('清空')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: LogPanel(lines: _logs)),
        ],
      ),
    );
  }
}
