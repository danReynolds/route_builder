import 'package:route_builder/arguments.dart';
import 'package:route_builder/arguments_factory.dart';
import 'package:route_builder/empty_arguments.dart';
import 'package:route_builder/route.dart';
import 'package:route_builder/route_factory.dart';
import 'package:route_builder/route_matcher.dart';

class Routes {
  static List<RouteMatcher> _routeMatchers = [];

  static void clear() {
    _routeMatchers = [];
  }

  static Route register(
    String name, {
    bool strictQueryParams = false,
  }) {
    final route = Route(
      name,
      strictQueryParams: false,
    );
    _routeMatchers.add(route);
    return route;
  }

  static RouteFactory<T> registerFactory<T extends Arguments>(
    String pathFormat, {
    required ArgumentsFactory<T> argsFactory,
    bool strictQueryParams = false,
  }) {
    final routeFactory = RouteFactory<T>(
      pathFormat,
      argsFactory: argsFactory,
      strictQueryParams: strictQueryParams,
    );
    _routeMatchers.add(routeFactory);
    return routeFactory;
  }

  static List<RouteWithArguments> allMatches(String? route) {
    if (route == null) {
      return [];
    }

    List<RouteWithArguments> allMatches = [];
    for (RouteMatcher _matcher in _routeMatchers) {
      if (_matcher.match(route)) {
        if (_matcher is RouteFactory) {
          allMatches.add(_matcher.parse(route)!);
        } else {
          allMatches.add(
            RouteWithArguments<EmptyArguments>(
              name: route,
              arguments: EmptyArguments(),
            ),
          );
        }
      }
    }

    return allMatches;
  }

  static RouteWithArguments? firstMatch(String? route) {
    if (route == null) {
      return null;
    }

    RouteMatcher? matcher;
    for (RouteMatcher _matcher in _routeMatchers) {
      if (_matcher.match(route)) {
        matcher = _matcher;
        break;
      }
    }

    if (matcher == null) {
      return null;
    }

    if (matcher is RouteFactory) {
      return matcher.parse(route);
    }

    return RouteWithArguments<EmptyArguments>(
      name: route,
      arguments: EmptyArguments(),
    );
  }
}
