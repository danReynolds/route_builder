part of route_builder;

extension UriExtensions on Uri {
  String get routeName {
    if (query.isEmpty) {
      return path;
    }

    return "$path?$query";
  }

  RouteWithArguments<T> toRoute<T extends Arguments>(T args) {
    return RouteWithArguments(name: routeName, arguments: args);
  }
}
