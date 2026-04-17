import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tutorial/project/application/auth_controller.dart';
import 'package:riverpod_tutorial/project/application/todos_controller.dart';
import 'package:riverpod_tutorial/project/data/auth_repository.dart';
import 'package:riverpod_tutorial/project/data/todo_repository.dart';
import 'package:riverpod_tutorial/project/model/models.dart';

void main() {
  group('TodosController (分层 + override)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // 给每个测试一个全新的 repo, 保证互不影响
          authRepositoryProvider
              .overrideWith((ref) => InMemoryAuthRepository()),
          todoRepositoryProvider
              .overrideWith((ref) => InMemoryTodoRepository(seedCount: 20)),
        ],
      );
      addTearDown(container.dispose);
    });

    test('未登录时 TodosController 返回空列表, page=0', () async {
      final page = await container.read(todosControllerProvider.future);
      expect(page.items, isEmpty);
      expect(page.page, 0);
      expect(page.hasMore, isFalse);
    });

    test('登录后首页加载 pageSize 条并 hasMore=true', () async {
      await container
          .read(authControllerProvider.notifier)
          .signIn('demo@x.com', 'pwd1');

      // 等 AuthController 更新到 Authenticated, TodosController 被重新 build
      await container.read(authControllerProvider.future);
      // invalidate 触发 todosController 重跑 (因为 auth 状态已变)
      final page = await container.read(todosControllerProvider.future);

      expect(page.items.length, TodosController.pageSize);
      expect(page.page, 1);
      expect(page.hasMore, isTrue);
    });

    test('loadMore 追加下一页', () async {
      await container
          .read(authControllerProvider.notifier)
          .signIn('demo@x.com', 'pwd1');
      await container.read(authControllerProvider.future);
      await container.read(todosControllerProvider.future);

      await container.read(todosControllerProvider.notifier).loadMore();

      final page = container.read(todosControllerProvider).value!;
      expect(page.items.length, greaterThan(TodosController.pageSize));
      expect(page.page, 2);
    });

    test('add 成功后列表最前面多一条', () async {
      await container
          .read(authControllerProvider.notifier)
          .signIn('demo@x.com', 'pwd1');
      await container.read(authControllerProvider.future);
      await container.read(todosControllerProvider.future);

      await container
          .read(todosControllerProvider.notifier)
          .add('全新待办事项');

      final items = container.read(todosControllerProvider).value!.items;
      expect(items.first.title, '全新待办事项');
    });

    test('signOut 后 todos 清空', () async {
      await container
          .read(authControllerProvider.notifier)
          .signIn('demo@x.com', 'pwd1');
      await container.read(authControllerProvider.future);
      await container.read(todosControllerProvider.future);

      await container.read(authControllerProvider.notifier).signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final page = await container.read(todosControllerProvider.future);
      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('AuthController', () {
    test('非法邮箱 signIn 进入 AsyncError', () async {
      final c = ProviderContainer(overrides: [
        authRepositoryProvider
            .overrideWith((ref) => InMemoryAuthRepository()),
      ]);
      addTearDown(c.dispose);

      await c.read(authControllerProvider.notifier).signIn('bad', 'pwd');
      final state = c.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('合法 signIn 后 state 变为 Authenticated', () async {
      final c = ProviderContainer(overrides: [
        authRepositoryProvider
            .overrideWith((ref) => InMemoryAuthRepository()),
      ]);
      addTearDown(c.dispose);

      await c.read(authControllerProvider.notifier).signIn('a@b.c', 'pwd1');
      final state = c.read(authControllerProvider).value;
      expect(state, isA<Authenticated>());
      expect((state as Authenticated).user.email, 'a@b.c');
    });
  });
}
