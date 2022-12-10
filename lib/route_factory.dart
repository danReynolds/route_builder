import 'package:route_builder/arguments.dart';
import 'package:route_builder/arguments_factory.dart';
import 'package:route_builder/path_arguments.dart';
import 'package:route_builder/route.dart';
import 'package:route_builder/route_matcher.dart';
import 'package:route_builder/uri.dart';

class RouteFactory<T extends Arguments> extends RouteMatcher {
  final ArgumentsFactory<T> argsFactory;
  late PathArguments _pathArguments;

  RouteFactory(
    String pathFormat, {
    required this.argsFactory,
    bool strictQueryParams = false,
  }) : super(
          name: pathFormat,
          strictQueryParams: strictQueryParams,
        ) {
    _pathArguments = PathArguments(Uri.decodeFull(uri.path));
  }

  RouteWithArguments<T> _buildRoute(T arguments) {
    final argsJson = arguments.toJson();
    final path = _pathArguments.buildPath(argsJson);

    // The remaining arguments that were not interpolated into the path
    // are added as query params.
    argsJson.removeWhere((key, _) =>
        _pathArguments.argsList.contains(key) || argsJson[key] == null);

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
    final parsedPathArgs = _pathArguments.parseArgs(uri.path);

    // The args JSON includes:
    // 1. Matched data from the args parser
    // 2. Data from the given URI query params
    // 3. Data from the route's provided query params
    Map<String, String> argsJson = {
      ...uri.queryParameters,
      ...this.uri.queryParameters,
      ...parsedPathArgs,
    };

    // If any of the required arguments are not present in the args map,
    // return null to indicate that the arguments could not be built.
    for (String argName in argsFactory.requiredArgs) {
      if (!argsJson.containsKey(argName)) {
        return null;
      }
    }

    return argsFactory.fromJson(argsJson);
  }

  @override
  matchPath(String? route) {
    if (route == null) {
      return false;
    }

    final uri = Uri.parse(route);

    // The path for a route factory must also match its path format.
    return this.uri.path.isEmpty || _pathArguments.match(uri.path);
  }

  @override
  match(String? route) {
    if (!super.match(route)) {
      return false;
    }

    // A route factory additionally validates that the route has all the required
    // arguments specified by the arguments factory which can be checked by attempting
    // to build the arguments for the given route.
    return _buildArgs(route) != null;
  }
}
