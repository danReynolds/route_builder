import 'package:flutter/widgets.dart';
import 'package:route_builder/arguments.dart';
import 'package:route_builder/config.dart';
import 'package:route_builder/route_matcher.dart';

class Route<AuthType> extends RouteMatcher<AuthType> {
  Route(
    String name, {
    bool strictQueryParams = false,
    AuthFn<AuthType>? authorize,
  }) : super(
          strictQueryParams: strictQueryParams,
          authorize: authorize ?? RouteConfig.instance.authorize,
          name: name,
        );

  RouteSettings get settings {
    return RouteSettings(name: name);
  }
}

class RouteWithArguments<T extends Arguments> extends Route {
  T arguments;

  RouteWithArguments({
    required String name,
    required this.arguments,
    AuthFn? authorize,
  }) : super(name, authorize: authorize);
}
