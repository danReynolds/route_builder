part of route_builder;

class Route extends _RouteMatcher {
  Route(
    super.name, {
    super.strictQueryParams = false,
  });

  String get name {
    // If no path was specified in the route, then it is a relative route
    // that should have a name relative to the current path.
    if (_uri.path.isEmpty) {
      return Uri(
        path: Uri.base.path,
        queryParameters: _uri.queryParameters,
      ).routeName;
    }

    return _uri.routeName;
  }

  /// Returns [name] appended to the base URI for the platform.
  Uri get withBase {
    return Uri.base.replace(
      path: _uri.path,
      queryParameters:
          _uri.queryParameters.isNotEmpty ? _uri.queryParameters : null,
    );
  }

  RouteSettings get settings {
    return RouteSettings(name: name);
  }
}

class RouteWithArguments<T extends Arguments> extends Route {
  final T arguments;

  RouteWithArguments({
    required String name,
    required this.arguments,
  }) : super(name);
}
