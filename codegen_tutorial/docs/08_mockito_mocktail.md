# 第 8 章 mockito / mocktail

## 目标

- 对照两个"制造 Mock 对象"的方案: mockito 用 codegen, mocktail 不用。
- 会用 `when / thenAnswer / verify` 三个动作写单测。
- 知道什么时候用哪个。

## mockito: 用 codegen

### 写法

```dart
// test/greeter_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'greeter_test.mocks.dart';        // <- 生成出来的

@GenerateMocks([UserRepository])
void main() {
  test('greet uses repo', () async {
    final repo = MockUserRepository();    // <- 生成出来的类
    when(repo.fetchName(1)).thenAnswer((_) async => 'Alice');

    final sut = Greeter(repo);
    expect(await sut.greet(1), 'Hello, Alice!');
    verify(repo.fetchName(1)).called(1);
  });
}
```

### 生成了什么

跑 `dart run build_runner build` 后会出现 `greeter_test.mocks.dart`, 里面就是一整份 `MockUserRepository` 的实现, 把 `UserRepository` 每个方法都改成"记录调用 + 返回 stub 的"骨架。

### 好处 / 坏处

优点:

- 一个注解就搞定, mock 类的所有方法自动有。
- `verify(mock.foo(any)).called(2)` 等丰富的断言 API。

缺点:

- 必须跑 build_runner, 每次改被 mock 的接口就得 rebuild。
- mock 出来的类要 import 一份生成文件 (`xxx.mocks.dart`)。

## mocktail: 不用 codegen

### 写法

```dart
import 'package:mocktail/mocktail.dart';

class MockUserRepo extends Mock implements UserRepository {}

void main() {
  test('greet uses repo', () async {
    final repo = MockUserRepo();
    when(() => repo.fetchName(1)).thenAnswer((_) async => 'Bob');

    final sut = Greeter(repo);
    expect(await sut.greet(1), 'Hello, Bob!');
    verify(() => repo.fetchName(1)).called(1);
  });
}
```

差别:

- 手写一个 `class MockX extends Mock implements X {}`, **一行**就完事。
- `when` 里要用闭包 `() => repo.fetchName(1)`, 不是直接写 `repo.fetchName(1)`。原因是 mocktail 通过 `Zone` 捕获调用, 避开 mockito 的类型系统限制。

### 好处 / 坏处

优点:

- 无 codegen, 改接口不用 rebuild, 编辑-测试循环更快。
- Null-safety 原生友好。

缺点:

- `when(() => ...)` 的闭包包装心智负担略高。
- 少数高级功能 (自动生成 getter 的 stub、`MockCubit` 扩展等) 不像 mockito 自己体系那么全。

## 对照表

| 维度 | mockito | mocktail |
|------|---------|----------|
| 是否 codegen | 是 | 否 |
| 定义 Mock | `@GenerateMocks([X])` | `class MockX extends Mock implements X {}` |
| stub | `when(x.f(1)).thenAnswer(...)` | `when(() => x.f(1)).thenAnswer(...)` |
| 任意参数 | `any` | `any()` |
| null-safety | 后补, 偶有坑 | 一开始就是 | 
| 改接口后 | 要 rebuild | 不用 | 
| 社区趋势 | 老项目多 | 新项目流行, bloc/cubit 生态默认 |

## 怎么选

- **新 Flutter 项目**: 优先 mocktail, 不用跑 build_runner, 保持测试简单快。
- **继承的老代码或团队约定**: 就按 mockito。
- **想要两者并存**: 也可以, 各自负责不同测试文件。

## 练习

1. 给 `UserRepository` 加一个方法 `Future<List<String>> searchByPrefix(String p)`, 写两份测试: mockito 一份 (别忘了重跑 build_runner), mocktail 一份。
2. 对同一个 `sut.greet(1)` 写 `verifyNever(...)` 断言: "当输入不是 1 时 fetchName 不被调用"。
3. 思考: mockito 能生成 mock, 背后其实也是 analyzer 读接口 + source_gen 写代码。和第 2 章自己写的 generator 在本质上有什么共同点?
