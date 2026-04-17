import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/models.dart';

abstract class TodoRepository {
  Future<List<Todo>> fetchPage(String userId, {required int page, required int size});
  Future<Todo> create(String userId, String title);
  Future<Todo> update(String userId, Todo todo);
  Future<void> remove(String userId, String id);
}

/// 内存实现 + 简单 "cache vs remote" 拆分, 演示离线兜底的思路。
class InMemoryTodoRepository implements TodoRepository {
  InMemoryTodoRepository({int seedCount = 23}) {
    for (var i = 1; i <= seedCount; i++) {
      _remote.add(Todo(id: 't$i', title: '初始 Todo #$i', done: i % 5 == 0));
    }
    _cache.addAll(_remote);
  }

  final List<Todo> _cache = [];
  final List<Todo> _remote = [];
  final _rng = Random();

  @override
  Future<List<Todo>> fetchPage(String userId,
      {required int page, required int size}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final start = (page - 1) * size;
    if (start >= _remote.length) return const [];
    final end = min(start + size, _remote.length);
    return _remote.sublist(start, end);
  }

  @override
  Future<Todo> create(String userId, String title) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final todo = Todo(
      id: 't-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
    );
    _remote.insert(0, todo);
    _cache.insert(0, todo);
    return todo;
  }

  @override
  Future<Todo> update(String userId, Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (_rng.nextInt(10) < 2) {
      throw Exception('服务器偶发错误');
    }
    final i = _remote.indexWhere((t) => t.id == todo.id);
    if (i >= 0) _remote[i] = todo;
    return todo;
  }

  @override
  Future<void> remove(String userId, String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _remote.removeWhere((t) => t.id == id);
    _cache.removeWhere((t) => t.id == id);
  }
}

final todoRepositoryProvider =
    Provider<TodoRepository>((ref) => InMemoryTodoRepository());
