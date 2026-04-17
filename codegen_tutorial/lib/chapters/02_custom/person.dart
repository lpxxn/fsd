import 'package:my_generator/my_generator.dart';

part 'person.g.dart';

/// 第 2 章演示: 用我们自己写的 `@ToStringGen` 注解生成 toString()。
///
/// 跑 `dart run build_runner build --delete-conflicting-outputs` 后,
/// 同目录会出现 person.g.dart, 里面就是 _$PersonToString 函数的定义。
@ToStringGen()
class Person {
  Person({required this.name, required this.age});
  final String name;
  final int age;

  @override
  String toString() => _$PersonToString(this);
}
