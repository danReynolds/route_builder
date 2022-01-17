import 'package:flutter/widgets.dart';
import 'package:route_builder/arguments.dart';
import 'package:route_builder/route_matcher.dart';
import 'package:route_builder/uri.dart';

class Route extends RouteMatcher {
  late String name;

  Route(
    String name, {
    bool strictQueryParams = false,
  }) : super(
          strictQueryParams: strictQueryParams,
          name: name,
        ) {
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
