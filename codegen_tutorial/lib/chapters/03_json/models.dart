import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// 最基础的用法: 加 @JsonSerializable, 实现 fromJson / toJson 两个"粘合代码"。
@JsonSerializable()
class User {
  User({
    required this.id,
    required this.name,
    this.email,
  });

  final int id;
  final String name;
  final String? email;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// 字段重命名 + 枚举 + 默认值。
@JsonSerializable()
class Article {
  Article({
    required this.id,
    required this.title,
    @JsonKey(name: 'author_name') required this.authorName,
    @JsonKey(defaultValue: Visibility.private) required this.visibility,
    this.tags = const [],
  });

  final int id;
  final String title;

  @JsonKey(name: 'author_name')
  final String authorName;

  final Visibility visibility;

  final List<String> tags;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}

enum Visibility {
  @JsonValue('public')
  public,
  @JsonValue('private')
  private,
  @JsonValue('unlisted')
  unlisted,
}

/// 嵌套对象 + explicit_to_json (我们在 build.yaml 里打开了)。
@JsonSerializable(explicitToJson: true)
class Post {
  Post({required this.author, required this.article});
  final User author;
  final Article article;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

/// 泛型 + genericArgumentFactories: 让 fromJson 拿到 "内层 T 如何反序列化" 的函数。
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  ApiResponse({required this.code, required this.data});
  final int code;
  final T data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
