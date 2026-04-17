import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tutorial/project/data/auth_repository.dart';
import 'package:riverpod_tutorial/project/data/todo_repository.dart';
import 'package:riverpod_tutorial/project/presentation/app.dart';

void main() {
  testWidgets('未登录 → 输入账号 → 登录 → 看到 Todo 列表', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider
              .overrideWith((ref) => InMemoryAuthRepository()),
          todoRepositoryProvider
              .overrideWith((ref) => InMemoryTodoRepository(seedCount: 12)),
        ],
        child: const MaterialApp(home: TodoApp()),
      ),
    );

    // 等初始 restore 完成
    await tester.pumpAndSettle();

    // 应该在登录页
    expect(find.text('Todo App · 登录'), findsOneWidget);

    // 点击登录按钮 (TextField 已预填)
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    // 登录后应进入列表页, AppBar 包含 "你好, demo"
    expect(find.textContaining('你好, demo'), findsOneWidget);

    // 至少显示几条 Todo
    expect(find.text('初始 Todo #1'), findsOneWidget);
  });
}
