# 第 3 章 json_serializable

## 目标

彻底告别手写 `fromJson`/`toJson`, 用 `@JsonSerializable()` 让 build_runner 替你生成。

## 最小例子

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User({required this.id, required this.name, this.email});
  final int id;
  final String name;
  final String? email;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

跑 `dart run build_runner build`, 生成:

```dart
// user.g.dart
User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.email case final value?) 'email': value,  // include_if_null: false
    };
```

就是你要手写的代码, 一个字段都没少, 一个字段都没多。

## 常用技巧

### 1. 字段重命名 `@JsonKey(name: 'xxx')`

```dart
@JsonKey(name: 'author_name')
final String authorName;
```

### 2. 默认值 `@JsonKey(defaultValue: ...)`

后端偶尔丢字段不给你崩:

```dart
@JsonKey(defaultValue: Visibility.private)
required this.visibility,
```

注意 `defaultValue` 必须是 **const 字面量** (数字/字符串/枚举)。

### 3. 枚举映射 `@JsonValue('xxx')`

```dart
enum Visibility {
  @JsonValue('public') public,
  @JsonValue('private') private,
}
```

序列化时存 `'public'`, 反序列化时按字符串还原。

### 4. 嵌套对象: `explicitToJson: true`

```dart
@JsonSerializable(explicitToJson: true)
class Post {
  final User author;
}
```

- 默认 `toJson()` 对内层 `User` 不会调 `.toJson()`, 会把整个对象塞进去 → JSON 编码时可能抛异常。
- 加 `explicitToJson: true` 后生成的 `toJson` 会显式 `author.toJson()`。
- 我们在 `build.yaml` 里把它设成全局默认, 永远写不丢。

### 5. 泛型: `genericArgumentFactories`

想表达 "响应都是 `{code, data}`, data 可能是 User/Article/List<Article>" 时:

```dart
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  ApiResponse({required this.code, required this.data});
  final int code;
  final T data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

// 用:
final resp = ApiResponse<User>.fromJson(json, (j) => User.fromJson(j as Map<String, dynamic>));
```

## 对照: 生成前 vs 生成后

| 你写的 | 生成的 `.g.dart` 里多了什么 |
|--------|---------------------------|
| `@JsonSerializable()` + `User` class | `_$UserFromJson(Map)` 和 `_$UserToJson(User)` 两个顶层函数 |
| `@JsonKey(name: 'author_name')` | `_$ArticleFromJson` 里改成读 `json['author_name']` |
| `@JsonKey(defaultValue: X)` | 读不到时 `?? X` |
| `@JsonValue('public')` enum | 生成 `$VisibilityEnumMap` 双向查找表 |
| `genericArgumentFactories: true` | 生成函数多一个 `T Function(Object?)` 参数 |

## 踩坑

1. **忘了写 `part 'xxx.g.dart';`** → "Undefined name '_$UserFromJson'" 或 "Outputs would collide" 错误。
2. **字段不是 `final`** 也能生成, 但不是 json_serializable 推荐姿势 (组合 freezed 更优雅)。
3. **类型必须明确**: 用 `dynamic` 或 `var` 时 generator 不知道该生成啥, 会给你 `cast to specific type` 风格的弱代码。
4. **`Duration` / `DateTime` 不是默认支持的**: 要自己写 `@JsonKey(fromJson: ..., toJson: ...)` 的自定义转换器。
5. **改了字段后记得 `build_runner build`**: 否则运行时还是按旧结构, 报 `type 'Null' is not a subtype of type 'String'`。

## 练习

1. 在 `lib/chapters/03_json/models.dart` 给 `User` 加一个 `DateTime createdAt` 字段, 用 `@JsonKey(fromJson: ..., toJson: ...)` 做 ISO-8601 字符串互转。
2. 构造一个 `ApiResponse<List<User>>` JSON, 走一遍 fromJson。想清楚那个 `fromJsonT` 参数该怎么传。
3. 看 `lib/chapters/03_json/models.g.dart` (build 后生成), 对比哪些是你预期的, 哪些有意外的 null 处理。
