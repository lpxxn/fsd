import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_controller.dart';
import '../model/models.dart';
import 'login_page.dart';
import 'todo_list_page.dart';

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return switch (auth) {
      AsyncData(:final value) when value is Authenticated =>
        const TodoListPage(),
      AsyncData() => const LoginPage(),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}
