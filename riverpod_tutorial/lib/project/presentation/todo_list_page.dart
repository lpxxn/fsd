import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_controller.dart';
import '../application/todos_controller.dart';
import '../model/models.dart';

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ConsumerState<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends ConsumerState<TodoListPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
        ref.read(todosControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).value;
    final user = (auth is Authenticated) ? auth.user : null;
    final todos = ref.watch(todosControllerProvider);

    ref.listen(todosControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('你好, ${user?.name ?? ''}'),
        actions: [
          IconButton(
            tooltip: '退出登录',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      hintText: '写个新 Todo 并回车',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: _submit,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _submit(_input.text),
                  child: const Text('添加'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(todos)),
        ],
      ),
    );
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    ref.read(todosControllerProvider.notifier).add(text.trim());
    _input.clear();
  }

  Widget _buildBody(AsyncValue<Paged<Todo>> todos) {
    return switch (todos) {
      AsyncError(:final error) when todos.value == null =>
        Center(child: Text('加载失败: $error')),
      AsyncValue(value: final page?) => RefreshIndicator(
          onRefresh: () =>
              ref.read(todosControllerProvider.notifier).refresh(),
          child: ListView.separated(
            controller: _scroll,
            itemCount: page.items.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, i) {
              if (i == page.items.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      page.hasMore ? '加载中...' : '没有更多了',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                );
              }
              final t = page.items[i];
              return ListTile(
                leading: Checkbox(
                  value: t.done,
                  onChanged: (_) =>
                      ref.read(todosControllerProvider.notifier).toggle(t.id),
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
                  onPressed: () => ref
                      .read(todosControllerProvider.notifier)
                      .remove(t.id),
                ),
              );
            },
          ),
        ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
