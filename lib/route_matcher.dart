part of route_builder;

abstract class _RouteMatcher {
  final Uri _uri;
  final bool strictQueryParams;

  _RouteMatcher(
    String name, {
    /// Require that the query params extracted from [name] *must* strictly match those
    /// provided in comparison matching.
    this.strictQueryParams = false,
  }) : _uri = Uri.parse(name);

  bool matchQueryParams(String? route) {
    if (route == null) {
      return false;
    }

    final uri = Uri.parse(route);
    final queryParams = _uri.queryParameters;
    final otherQueryParams = uri.queryParameters;

    if (strictQueryParams) {
      return mapEquals(queryParams, otherQueryParams);
    }

    for (String key in queryParams.keys) {
      if (queryParams[key] != otherQueryParams[key]) {
        return false;
      }
    }
    return true;
  }

  bool matchPath(String? route) {
    if (route == null) {
      return false;
    }

    return Uri.parse(route).path == _uri.path;
  }

  bool match(String? route) {
    return matchPath(route) && matchQueryParams(route);
  }
}
