import 'package:codegen_tutorial/chapters/08_mock/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mockito_generate_test.mocks.dart';

/// 第 8 章 · mockito: 声明要 mock 的类, build_runner 生成 MockXxx。
@GenerateMocks([UserRepository])
void main() {
  test('mockito 生成的 MockUserRepository 能 stub 行为', () async {
    final repo = MockUserRepository();
    when(repo.fetchName(1)).thenAnswer((_) async => 'Alice');

    final sut = Greeter(repo);
    expect(await sut.greet(1), 'Hello, Alice!');
    verify(repo.fetchName(1)).called(1);
  });
}
