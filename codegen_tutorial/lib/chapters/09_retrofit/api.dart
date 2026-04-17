import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'models.dart';

part 'api.g.dart';

/// 声明一组 HTTP 接口, build_runner 会生成基于 dio 的实现 `_JsonPlaceholderApi`。
///
/// 用公共 API: https://jsonplaceholder.typicode.com
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
