# 第 9 章 retrofit: 把接口声明变成 dio 调用

## 目标

- 用 **抽象接口 + 注解** 描述一组 HTTP 接口, 让 `retrofit_generator` 帮你生成基于 `dio` 的实现。
- 核心注解: `@RestApi` / `@GET` / `@POST` / `@Path` / `@Query` / `@Body`。

## 最小例子

```dart
@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com/')
abstract class JsonPlaceholderApi {
  factory JsonPlaceholderApi(Dio dio, {String baseUrl}) = _JsonPlaceholderApi;

  @GET('/posts')
  Future<List<Post>> listPosts();

  @GET('/posts/{id}')
  Future<Post> getPost(@Path('id') int id);

  @POST('/posts')
  Future<Post> createPost(@Body() Post post);
}
```

跑 `dart run build_runner build` 后, `api.g.dart` 里会出现 `_JsonPlaceholderApi` 实现:

```dart
class _JsonPlaceholderApi implements JsonPlaceholderApi {
  _JsonPlaceholderApi(this._dio, {this.baseUrl});
  final Dio _dio;
  String? baseUrl;

  @override
  Future<List<Post>> listPosts() async {
    final _result = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(
        _dio.options, '/posts', baseUrl: baseUrl ?? 'https://jsonplaceholder.typicode.com/',
      ),
    );
    return (_result.data ?? [])
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Post> getPost(int id) async {
    final _result = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/posts/$id', baseUrl: baseUrl ?? ...),
    );
    return Post.fromJson(_result.data!);
  }

  @override
  Future<Post> createPost(Post post) async {
    final _data = post.toJson();
    final _result = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(
        _dio.options, '/posts', data: _data, baseUrl: baseUrl ?? ...,
      ),
    );
    return Post.fromJson(_result.data!);
  }
}
```

对比你自己手写: 省掉每个方法 10+ 行 dio 调用 + `Post.fromJson` 映射。

## 常用注解一览

| 注解 | 作用 | 例子 |
|------|------|------|
| `@RestApi(baseUrl: '...')` | 打在抽象类上, 指定 baseUrl | 见上 |
| `@GET/@POST/@PUT/@DELETE` | HTTP method + path | `@GET('/users/{id}')` |
| `@Path('id')` | 拼路径参数 | `@GET('/users/{id}') Future<User> get(@Path('id') int id);` |
| `@Query('q')` | URL 参数 | `Future<List<X>> search(@Query('q') String q);` |
| `@Queries()` | 一次塞一组 | `@Queries() Map<String, dynamic> params` |
| `@Body()` | 请求体 (自动 `toJson()`) | `createPost(@Body() Post p)` |
| `@Headers({...})` / `@Header('X-Token')` | 静态 / 动态头 | |
| `@Part()` / `@MultiPart()` | multipart/form-data 上传 | |
| `@Field('f')` | application/x-www-form-urlencoded | |

## 拦截器 & 认证

retrofit 只负责"把接口方法翻译成 dio 调用"。认证、日志、重试、缓存都交给 dio 的 `Interceptor`:

```dart
final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)))
  ..interceptors.addAll([
    LogInterceptor(responseBody: true),
    AuthInterceptor(tokenProvider: () => 'xxx'),
  ]);
final api = JsonPlaceholderApi(dio);
```

## 和 json_serializable / freezed 配合

- Response 类型 (比如 `Post`) 必须是能 `fromJson` / `toJson` 的。
- 直接用 `@JsonSerializable()` 或 `@freezed` 都行。
- 如果返回泛型 (`Future<ApiResponse<Post>>`), 需要 `genericArgumentFactories: true` (第 3 章已讲)。

## 常见坑

1. **忘了给返回类型加 `fromJson`**: retrofit 生成的代码直接调 `Post.fromJson(...)`, 没这个方法就 runtime 报错。
2. **`@Body()` 传 `Map<String, dynamic>` 而不是 DTO**: 可以, 但失去类型安全, 慎用。
3. **baseUrl 尾斜杠**: `baseUrl` 带尾斜杠 `/`, 然后 path 不带前导斜杠 `/`, 或者反过来。保持一边带一边不带, 最稳。
4. **文件上传接口要加 `@MultiPart()`**: 否则 dio 发的还是 JSON, 后端解析失败。
5. **别在 release 里开 LogInterceptor**: 性能和日志噪音都很吃亏。

## 在本工程的 Demo

`lib/chapters/chapter_09_page.dart` 构造一个 dio + JsonPlaceholderApi, 点按钮调 `getPost(1)`, 展示 JSON 结果。
注意 **需要网络**, 没网会看到 dio error。

## 练习

1. 在 `api.dart` 加一个 `@GET('/posts') Future<List<Post>> searchByUser(@Query('userId') int userId)`, 跑 build_runner, 对比生成代码。
2. 把 `createPost` 的返回类型改成 `Future<Post>`, 传的 body 里故意丢 `id`, 观察真实接口返回新 id 时 `Post.fromJson` 行不行。
3. 写一个 `LoggingInterceptor`, 打印请求 URL + 响应状态码。感受 retrofit + dio 的分层。
