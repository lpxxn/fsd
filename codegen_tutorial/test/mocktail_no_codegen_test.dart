import 'package:codegen_tutorial/chapters/08_mock/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// 第 8 章 · mocktail: 无 codegen, 直接继承 Mock + 目标接口即可。
class MockUserRepo extends Mock implements UserRepository {}

void main() {
  test('mocktail 手写 Mock 类, 用法几乎一样', () async {
    final repo = MockUserRepo();
    when(() => repo.fetchName(1)).thenAnswer((_) async => 'Bob');

    final sut = Greeter(repo);
    expect(await sut.greet(1), 'Hello, Bob!');
    verify(() => repo.fetchName(1)).called(1);
  });
}
