import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/models.dart';

abstract class AuthRepository {
  Future<User?> restore();
  Future<User> signIn(String email, String password);
  Future<void> signOut();
}

/// 内存实现：任何非空邮箱 + 长度 >= 4 的密码均可登录；登录后持久到 _saved 里模拟"本地 token"。
class InMemoryAuthRepository implements AuthRepository {
  User? _saved;

  @override
  Future<User?> restore() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _saved;
  }

  @override
  Future<User> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!email.contains('@') || password.length < 4) {
      throw Exception('邮箱或密码不合法');
    }
    _saved = User(
      id: 'u-${email.hashCode.abs()}',
      name: email.split('@').first,
      email: email,
    );
    return _saved!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _saved = null;
  }
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => InMemoryAuthRepository());
