part of route_builder;

abstract class RouteMatcher {
  final Uri _uri;
  final bool strictQueryParams;

  RouteMatcher(
    String name, {
    this.strictQueryParams = false,
  }) : _uri = Uri.parse(name);

  bool matchQueryParams(String? route) {
    if (route == null) {
      return false;
    }

    final uri = Uri.parse(route);
    final queryParams = _uri.queryParameters;
    final testQueryParams = uri.queryParameters;

    if (strictQueryParams) {
      return mapEquals(queryParams, testQueryParams);
    } else {
      for (String key in queryParams.keys) {
        if (testQueryParams[key] != queryParams[key]) {
          return false;
        }
      }
      return true;
    }
  }

  bool matchPath(String? route) {
    if (route == null) {
      return false;
    }

    final uri = Uri.parse(route);

    return _uri.path.isEmpty || uri.path == _uri.path;
  }

  bool match(String? route) {
    return matchPath(route) && matchQueryParams(route);
  }
}
