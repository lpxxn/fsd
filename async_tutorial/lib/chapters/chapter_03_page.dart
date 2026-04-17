import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 3 章：async / await。把 .then 链改写为顺序代码。
class Chapter03Page extends StatefulWidget {
  const Chapter03Page({super.key});

  @override
  State<Chapter03Page> createState() => _Chapter03PageState();
}

class _Chapter03PageState extends State<Chapter03Page> {
  final List<String> _logs = [];
  bool _busy = false;

  void _log(String s) => setState(() => _logs.add(s));

  Future<int> _login() =>
      Future.delayed(const Duration(milliseconds: 400), () => 1001);
  Future<String> _fetchUser(int token) => Future.delayed(
      const Duration(milliseconds: 400), () => 'user#$token');
  Future<List<String>> _fetchOrders(String user, {bool fail = false}) =>
      Future.delayed(const Duration(milliseconds: 400), () {
        if (fail) throw Exception('订单服务挂了');
        return ['o1', 'o2', 'o3'];
      });

  Future<void> _runHappy() async {
    setState(() {
      _busy = true;
      _logs.clear();
    });
    _log('开始 async/await 流程...');
    try {
      final token = await _login();
      _log('  登录成功 token=$token');
      final user = await _fetchUser(token);
      _log('  用户 $user');
      final orders = await _fetchOrders(user);
      _log('  订单数 ${orders.length}');
      _log('全部完成');
    } catch (e) {
      _log('捕获异常: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runFailure() async {
    setState(() {
      _busy = true;
      _logs.clear();
    });
    _log('开始 (故意让订单接口抛错)...');
    try {
      final token = await _login();
      final user = await _fetchUser(token);
      await _fetchOrders(user, fail: true);
      _log('不会到这里');
    } catch (e) {
      _log('try/catch 接住: $e');
    } finally {
      _log('finally 收尾');
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '03 · async / await',
      intro: 'async/await 把 .then 链改写成像同步一样好读的代码。'
          '错误用 try/catch 处理，比 .catchError 更直观。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: _busy ? null : _runHappy,
                child: const Text('顺序流程 (成功)'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _runFailure,
                child: const Text('顺序流程 (失败)'),
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
