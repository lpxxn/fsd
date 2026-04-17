import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/chapter_scaffold.dart';

/// 第 3 章：Notifier 可变状态 (手写)。
/// 同时演示简单状态 (int) 和复合状态 (LoginForm)。

// ---- 计数器 ----
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

// ---- 复合状态：登录表单 ----
class LoginForm {
  const LoginForm({this.email = '', this.password = '', this.submitting = false});
  final String email;
  final String password;
  final bool submitting;

  bool get valid => email.contains('@') && password.length >= 4;

  LoginForm copyWith({String? email, String? password, bool? submitting}) =>
      LoginForm(
        email: email ?? this.email,
        password: password ?? this.password,
        submitting: submitting ?? this.submitting,
      );
}

class LoginFormNotifier extends Notifier<LoginForm> {
  @override
  LoginForm build() => const LoginForm();

  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  Future<void> submit() async {
    state = state.copyWith(submitting: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(submitting: false);
  }
}

final loginFormProvider =
    NotifierProvider<LoginFormNotifier, LoginForm>(LoginFormNotifier.new);

class Chapter03Page extends ConsumerWidget {
  const Chapter03Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final form = ref.watch(loginFormProvider);

    return ChapterScaffold(
      title: '03 · Notifier 可变状态',
      intro: 'Notifier<T> 定义可变状态: build() 返回初始值, '
          '通过 state = newValue 通知订阅者。',
      child: ListView(
        children: [
          // 简单计数器
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('计数器', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('$count', style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(counterProvider.notifier).decrement(),
                        child: const Text('-1'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(counterProvider.notifier).reset(),
                        child: const Text('重置'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(counterProvider.notifier).increment(),
                        child: const Text('+1'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 复合状态表单
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('登录表单 (复合状态)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: '邮箱'),
                    onChanged: (v) =>
                        ref.read(loginFormProvider.notifier).setEmail(v),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '密码'),
                    obscureText: true,
                    onChanged: (v) =>
                        ref.read(loginFormProvider.notifier).setPassword(v),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '表单有效: ${form.valid}  |  提交中: ${form.submitting}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: form.valid && !form.submitting
                            ? () => ref.read(loginFormProvider.notifier).submit()
                            : null,
                        child: form.submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('模拟提交'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
