import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';
import '04_freezed/models.dart';

/// 第 4 章 Demo: freezed 的三种形态实战。
class Chapter04Page extends StatefulWidget {
  const Chapter04Page({super.key});

  @override
  State<Chapter04Page> createState() => _Chapter04PageState();
}

class _Chapter04PageState extends State<Chapter04Page> {
  Todo _todo = const Todo(id: '1', title: 'learn freezed');
  CartItem _cart = const CartItem(sku: 'A-001', unitPrice: 12.5, quantity: 2);
  LoadState<int> _state = const LoadState<int>.idle();

  String _describe(LoadState<int> s) => switch (s) {
        LoadIdle() => '未开始',
        LoadLoading() => '加载中…',
        LoadSuccess(:final data) => '成功: $data',
        LoadFailure(:final error) => '失败: $error',
      };

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '04 · freezed',
      intro: '三种最常见形态: 普通 data class (Todo) · 带方法的 (CartItem) · sealed/union (LoadState)。'
          '注意每次 copyWith 都是新对象, == 按值相等。',
      child: ListView(
        children: [
          _card(
            '1. 普通 data class',
            [
              Text('todo = $_todo'),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _todo = _todo.copyWith(done: !_todo.done)),
                    child: const Text('toggle done (copyWith)'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      final newTodo = const Todo(id: '1', title: 'learn freezed');
                      final equal = _todo == newTodo;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('值相等? $equal (默认 done=false)')),
                      );
                    },
                    child: const Text('== 判等'),
                  ),
                ],
              ),
            ],
          ),
          _card(
            '2. 带方法: CartItem.total',
            [
              Text('cart = $_cart'),
              Text('cart.total = ¥${_cart.total.toStringAsFixed(2)}'),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _cart = _cart.copyWith(quantity: _cart.quantity + 1)),
                    child: const Text('quantity +1'),
                  ),
                  OutlinedButton(
                    onPressed: () => setState(() => _cart = _cart.copyWith(unitPrice: _cart.unitPrice + 1)),
                    child: const Text('unitPrice +1'),
                  ),
                ],
              ),
            ],
          ),
          _card(
            '3. sealed / union: LoadState<int>',
            [
              Text('state = $_state'),
              Text('describe = ${_describe(_state)}'),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(onPressed: () => setState(() => _state = const LoadState<int>.idle()), child: const Text('idle')),
                  TextButton(onPressed: () => setState(() => _state = const LoadState<int>.loading()), child: const Text('loading')),
                  TextButton(onPressed: () => setState(() => _state = const LoadState<int>.success(42)), child: const Text('success(42)')),
                  TextButton(onPressed: () => setState(() => _state = LoadState<int>.failure('boom')), child: const Text('failure')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
