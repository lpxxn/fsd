import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../model/models.dart';

class AuthController extends AsyncNotifier<AuthState> {
  late AuthRepository _repo;

  @override
  Future<AuthState> build() async {
    _repo = ref.watch(authRepositoryProvider);
    final restored = await _repo.restore();
    return restored != null ? Authenticated(restored) : const Unauthenticated();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repo.signIn(email, password);
      return Authenticated(user);
    });
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(Unauthenticated());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);
