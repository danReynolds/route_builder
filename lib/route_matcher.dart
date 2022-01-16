import 'package:flutter/foundation.dart';
import 'package:route_builder/config.dart';
import 'package:route_builder/uri.dart';

abstract class RouteMatcher<AuthType> {
  final AuthFn<AuthType>? authorize;
  late final String name;
  late final Uri uri;
  bool strictQueryParams;

  RouteMatcher({
    required this.authorize,
    required String name,
    this.strictQueryParams = false,
  }) {
    uri = Uri.parse(name);

    // If the provided route name has no path and is just query parameters,
    // then append it to the current path.
    if (uri.path.isEmpty) {
      this.name = Uri(
        path: Uri.base.path,
        queryParameters: uri.queryParameters,
      ).pathWithQuery;
    } else {
      this.name = name;
    }
  }

  bool isAuthorized([AuthType? args]) {
    return authorize == null || authorize!(args);
  }

  bool isAuthorizedMatch(AuthType? args, String? route) {
    return isAuthorized(args) && match(route);
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
