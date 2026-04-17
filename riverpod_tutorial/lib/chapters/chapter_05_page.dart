import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 5 章：AsyncNotifier + 乐观更新。
/// 用内存模拟一个 Todo 列表，每个方法带延迟，部分带随机失败。

class Todo {
  const Todo({required this.id, required this.title, this.done = false});
  final String id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(id: id, title: title ?? this.title, done: done ?? this.done);
}

final _rng = Random();

class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Todo(id: '1', title: '学 Riverpod'),
      Todo(id: '2', title: '写业务代码'),
    ];
  }

  Future<void> add(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      final list = state.value ?? [];
      return [
        ...list,
        Todo(id: '${DateTime.now().millisecondsSinceEpoch}', title: title),
      ];
    });
  }

  /// 乐观更新：UI 立即反映，失败回滚。
  Future<void> toggle(String id) async {
    final oldList = state.value ?? [];
    final target = oldList.firstWhere((t) => t.id == id);
    final newList = oldList
        .map((t) => t.id == id ? t.copyWith(done: !t.done) : t)
        .toList();

    state = AsyncData(newList);

    await Future.delayed(const Duration(milliseconds: 400));
    if (_rng.nextInt(10) < 3) {
      state = AsyncData(oldList);
      throw Exception('toggle ${target.title} 服务器失败, 已回滚');
    }
  }

  Future<void> remove(String id) async {
    final oldList = state.value ?? [];
    state = AsyncData(oldList.where((t) => t.id != id).toList());
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

final todosProvider =
    AsyncNotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);

class Chapter05Page extends ConsumerStatefulWidget {
  const Chapter05Page({super.key});

  @override
  ConsumerState<Chapter05Page> createState() => _Chapter05PageState();
}

class _Chapter05PageState extends ConsumerState<Chapter05Page> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listen 用于把 AsyncError 以 SnackBar 暴露出来
    ref.listen<AsyncValue<List<Todo>>>(todosProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${next.error}')),
        );
      }
    });

    final todos = ref.watch(todosProvider);

    return ChapterScaffold(
      title: '05 · AsyncNotifier',
      intro: '异步可变状态: build() 异步返回初始值, '
          '方法通过 state = await AsyncValue.guard(...) 更新。'
          '点击 todo 切换完成状态有 30% 概率失败并回滚。',
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: '新 Todo 标题'),
                onSubmitted: _submit,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _submit(_controller.text),
              child: const Text('添加'),
            ),
            IconButton(
              tooltip: '刷新',
              onPressed: () => ref.invalidate(todosProvider),
              icon: const Icon(Icons.refresh),
            ),
          ]),
          const SizedBox(height: 8),
          Expanded(child: _buildList(todos)),
        ],
      ),
    );
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    ref.read(todosProvider.notifier).add(text.trim());
    _controller.clear();
  }

  Widget _buildList(AsyncValue<List<Todo>> todos) {
    return switch (todos) {
      AsyncError(:final error) => Center(child: Text('加载失败: $error')),
      AsyncValue(:final value) when value != null => Stack(
          children: [
            ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, i) {
                final t = value[i];
                return ListTile(
                  leading: Checkbox(
                    value: t.done,
                    onChanged: (_) =>
                        ref.read(todosProvider.notifier).toggle(t.id),
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: t.done ? TextDecoration.lineThrough : null,
                      color: t.done ? Colors.grey : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        ref.read(todosProvider.notifier).remove(t.id),
                  ),
                );
              },
            ),
            if (todos.isLoading)
              const Positioned(
                top: 0, left: 0, right: 0,
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
