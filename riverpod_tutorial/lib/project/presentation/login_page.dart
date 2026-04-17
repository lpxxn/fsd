import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController(text: 'demo@riverpod.dev');
  final _pwdCtrl = TextEditingController(text: 'demo');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final submitting = auth.isLoading;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Todo App · 登录')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: '邮箱',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码 (至少 4 位)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: submitting
                    ? null
                    : () => ref
                        .read(authControllerProvider.notifier)
                        .signIn(_emailCtrl.text, _pwdCtrl.text),
                child: submitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('登录'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '(Demo: 任何 name@xx.com + 至少 4 位密码即可登录, 偶发失败演示错误处理)',
              style: TextStyle(color: Colors.black54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
