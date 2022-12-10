import 'package:flutter/widgets.dart';
import 'package:route_builder/arguments.dart';
import 'package:route_builder/route_matcher.dart';
import 'package:route_builder/uri.dart';

class Route extends RouteMatcher {
  Route(
    String name, {
    bool strictQueryParams = false,
  }) : super(
          strictQueryParams: strictQueryParams,
          name: name,
        );

  String get name {
    // If no path was specified in the route, then it is a relative route
    // that should have a name relative to the current path.
    if (uri.path.isEmpty) {
      return Uri(
        path: Uri.base.path,
        queryParameters: uri.queryParameters,
      ).pathWithQuery;
    }

    return uri.pathWithQuery;
  }

  Uri get withBase {
    return Uri.base.replace(
      path: uri.path,
      queryParameters:
          uri.queryParameters.isNotEmpty ? uri.queryParameters : null,
    );
  }

  RouteSettings get settings {
    return RouteSettings(name: name);
  }
}

class RouteWithArguments<T extends Arguments> extends Route {
  T arguments;

  RouteWithArguments({
    required String name,
    required this.arguments,
  }) : super(name);
}
