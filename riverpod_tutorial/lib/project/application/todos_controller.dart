import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/todo_repository.dart';
import '../model/models.dart';
import 'auth_controller.dart';

class TodosController extends AsyncNotifier<Paged<Todo>> {
  static const pageSize = 8;

  TodoRepository get _repo => ref.read(todoRepositoryProvider);
  String? get _userId {
    final auth = ref.read(authControllerProvider).value;
    return auth is Authenticated ? auth.user.id : null;
  }

  @override
  Future<Paged<Todo>> build() async {
    // 依赖 auth: 登出时自动变回空列表
    final auth = ref.watch(authControllerProvider).value;
    if (auth is! Authenticated) {
      return const Paged(items: [], page: 0, hasMore: false);
    }
    final repo = ref.watch(todoRepositoryProvider);
    final items = await repo.fetchPage(auth.user.id, page: 1, size: pageSize);
    return Paged(items: items, page: 1, hasMore: items.length == pageSize);
  }

  Future<void> loadMore() async {
    final cur = state.value;
    final uid = _userId;
    if (cur == null || !cur.hasMore || uid == null) return;

    final nextPage = cur.page + 1;
    final more = await _repo.fetchPage(uid, page: nextPage, size: pageSize);
    state = AsyncData(Paged(
      items: [...cur.items, ...more],
      page: nextPage,
      hasMore: more.length == pageSize,
    ));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> add(String title) async {
    final uid = _userId;
    if (uid == null) return;
    state = await AsyncValue.guard(() async {
      final created = await _repo.create(uid, title);
      final cur = state.value ?? const Paged(items: [], page: 1, hasMore: false);
      return cur.copyWith(items: [created, ...cur.items]);
    });
  }

  /// 乐观更新：立即切换 done 状态, 失败则回滚。
  Future<void> toggle(String id) async {
    final uid = _userId;
    final cur = state.value;
    if (uid == null || cur == null) return;

    final index = cur.items.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final old = cur.items[index];
    final updated = old.copyWith(done: !old.done);
    final optimistic = [...cur.items]..[index] = updated;
    state = AsyncData(cur.copyWith(items: optimistic));

    try {
      await _repo.update(uid, updated);
    } catch (e, st) {
      // 失败: 先回滚到旧数据, 再发一次 AsyncError 让 ref.listen 弹 SnackBar,
      // 最后立即把 state 恢复成 AsyncData(cur) 以便 UI 继续显示列表。
      state = AsyncError<Paged<Todo>>(e, st);
      state = AsyncData(cur);
    }
  }

  Future<void> remove(String id) async {
    final uid = _userId;
    final cur = state.value;
    if (uid == null || cur == null) return;
    state = AsyncData(cur.copyWith(
      items: cur.items.where((t) => t.id != id).toList(),
    ));
    try {
      await _repo.remove(uid, id);
    } catch (e) {
      state = AsyncData(cur);
    }
  }
}

final todosControllerProvider =
    AsyncNotifierProvider<TodosController, Paged<Todo>>(TodosController.new);
