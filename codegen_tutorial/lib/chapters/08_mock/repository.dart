/// 要被 mock 的业务接口。mockito/mocktail 都围绕它演示。
abstract class UserRepository {
  Future<String> fetchName(int id);
  Future<void> delete(int id);
}

/// 被测的业务逻辑, 拿 repository 组合出结果。
class Greeter {
  Greeter(this.repo);
  final UserRepository repo;

  Future<String> greet(int userId) async {
    final name = await repo.fetchName(userId);
    return 'Hello, $name!';
  }
}
