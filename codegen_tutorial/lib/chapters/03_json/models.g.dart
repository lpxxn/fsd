// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': ?instance.email,
};

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  authorName: json['author_name'] as String,
  visibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['visibility']) ??
      Visibility.private,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author_name': instance.authorName,
  'visibility': _$VisibilityEnumMap[instance.visibility]!,
  'tags': instance.tags,
};

const _$VisibilityEnumMap = {
  Visibility.public: 'public',
  Visibility.private: 'private',
  Visibility.unlisted: 'unlisted',
};

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  author: User.fromJson(json['author'] as Map<String, dynamic>),
  article: Article.fromJson(json['article'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'author': instance.author.toJson(),
  'article': instance.article.toJson(),
};

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  code: (json['code'] as num).toInt(),
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'code': instance.code, 'data': toJsonT(instance.data)};
