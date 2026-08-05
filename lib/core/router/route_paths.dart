/// Central registry of route paths, so features reference a constant
/// instead of a magic string when navigating.
abstract class RoutePaths {
  static const root = '/';
  static const login = '/login';
  static const register = '/register';

  static const posts = '/posts';
  static const newPost = '/posts/new';

  static String postDetailPath(int id) => '/posts/$id';
  static String editPostPath(int id) => '/posts/$id/edit';
}
