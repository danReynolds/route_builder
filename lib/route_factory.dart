import 'package:route_builder/arguments.dart';
import 'package:route_builder/arguments_factory.dart';
import 'package:route_builder/route_path.dart';
import 'package:route_builder/config.dart';
import 'package:route_builder/route.dart';
import 'package:route_builder/route_matcher.dart';
import 'package:route_builder/uri.dart';

class RouteFactory<T extends Arguments> extends RouteMatcher {
  final ArgumentsFactory<T> argsFactory;
  late RoutePath _routePath;

  RouteFactory(
    String name, {
    required this.argsFactory,
    AuthFn? authorize,
  }) : super(name: name, authorize: authorize) {
    _routePath = RoutePath(Uri.decodeFull(uri.path));
  }

  RouteWithArguments<T> _buildRoute(T arguments) {
    final argsJson = arguments.toJson();
    final path = _routePath.build(argsJson);

    // The remaining arguments that were not interpolated into the path
    // are added as query params.
    argsJson.removeWhere((key, _) => _routePath.argsList.contains(key));

    final name = Uri(path: path, queryParameters: {
      ...uri.queryParameters,
      ...argsJson,
    }).pathWithQuery;

    return RouteWithArguments(name: name, arguments: arguments);
  }

  RouteWithArguments<T> call(T args) {
    return _buildRoute(args);
  }

  RouteWithArguments<T>? parse(String? route) {
    if (!match(route)) {
      return null;
    }

    return _buildRoute(_buildArgs(route)!);
  }

  T? _buildArgs(String? route) {
    if (route == null) {
      return null;
    }

    final uri = Uri.parse(route);
    final parsedArgs = _routePath.parseArgs(uri.path);

    // The args JSON includes:
    // 1. Matched data from the args parser
    // 2. Data from the given URI query params
    // 3. Data from the route's provided query params
    Map<String, String> argsJson = {
      ...uri.queryParameters,
      ...this.uri.queryParameters,
      ...parsedArgs,
    };

    return argsFactory.fromJson(argsJson);
  }

  @override
  matchPath(String? route) {
    if (route == null) {
      return false;
    }

    final uri = Uri.parse(route);

    return this.uri.path.isEmpty || _routePath.match(uri.path);
  }
}
