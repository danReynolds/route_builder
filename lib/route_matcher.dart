import 'package:flutter/foundation.dart';

abstract class RouteMatcher {
  late final Uri uri;
  bool strictQueryParams;

  RouteMatcher({
    required String name,
    this.strictQueryParams = false,
  }) {
    uri = Uri.parse(name);
  }

  bool matchQueryParams(String? route) {
    if (route == null) {
      return false;
    }

    final uri = Uri.parse(route);
    final queryParams = this.uri.queryParameters;
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

    return this.uri.path.isEmpty || uri.path == this.uri.path;
  }

  bool match(String? route) {
    return matchPath(route) && matchQueryParams(route);
  }
}
