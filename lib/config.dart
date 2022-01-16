typedef AuthFn<T> = bool Function([T? args]);

class RouteConfig {
  AuthFn? authorize;

  RouteConfig._();

  static final instance = RouteConfig._();

  static configure({
    AuthFn? authorize,
  }) {
    instance.authorize = authorize;
  }
}
