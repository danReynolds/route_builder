part of route_builder;

class ArgumentRouteFactory<T extends Arguments> extends _RouteMatcher {
  final ArgumentsFactory<T> _argsFactory;

  final _argsRegex = RegExp('{(.*?)}');
  static const _buildArgFragment = "[\\w\\d-]+?";

  final Set<String> _args = {};
  late final String _path = Uri.decodeFull(_uri.path);
  late final RegExp _pathRegex;

  ArgumentRouteFactory(
    String rawPath,
    this._argsFactory, {
    bool strictQueryParams = false,
  }) : super(rawPath, strictQueryParams: strictQueryParams) {
    // Build the path regex and args list.
    String path = _path;
    while (true) {
      final match = _argsRegex.firstMatch(path);
      if (match == null) {
        break;
      }

      final argName = match.group(1)!;
      path = path.replaceFirst(
        _argsRegex,
        "(?<$argName>$_buildArgFragment)",
      );
      _args.add(argName);
    }

    _pathRegex = RegExp("^$path\$");
  }

  T? _buildArgs(String? route) {
    if (route == null) {
      return null;
    }

    final uri = Uri.parse(route);
    final parsedPathArgs = _extractArgs(uri.path);

    // The args JSON includes the following in the specified order of precedence:
    // 1. Matched data from the args parser
    // 2. Data from the route's own query params
    // 3. Data from the given URI query params
    Map<String, String> argsJson = {
      ...uri.queryParameters,
      ..._uri.queryParameters,
      ...parsedPathArgs,
    };

    // If any of the required arguments are not present in the args map,
    // return null to indicate that the arguments could not be built.
    for (String argName in _argsFactory.requiredArgs) {
      if (!argsJson.containsKey(argName)) {
        return null;
      }
    }

    return _argsFactory.fromJson(argsJson);
  }

  /// Builds a route from the given args, interpolating fields in the path
  /// and query parameters with the matching argument values.
  RouteWithArguments<T> build(T args) {
    final argsJson = args.toJson();

    String interpolatedPath = _path;
    while (_argsRegex.hasMatch(interpolatedPath)) {
      final argName = _argsRegex.firstMatch(interpolatedPath)!.group(1)!;
      interpolatedPath =
          interpolatedPath.replaceFirst(_argsRegex, argsJson[argName]!);
      argsJson.remove(argName);
    }

    return Uri(path: interpolatedPath, queryParameters: {
      ..._uri.queryParameters,
      ...argsJson,
    }).toRoute(args);
  }

  RouteWithArguments<T>? parse(String? route) {
    if (!match(route)) {
      return null;
    }
    return build(_buildArgs(route)!);
  }

  /// Extracts a [Map] of args from the given path.
  Map<String, String> _extractArgs(String? path) {
    Map<String, String> argsJson = {};
    final argMatches = _pathRegex.firstMatch(path!);

    for (String argName in _args) {
      if (argMatches != null) {
        String matchedGroup = argMatches.namedGroup(argName)!;
        argsJson[argName] = matchedGroup;
      }
    }

    return argsJson;
  }

  @override
  matchPath(String? route) {
    if (route == null) {
      return false;
    }

    // Check that the route's path matches the factory's path format.
    return _pathRegex.hasMatch(Uri.parse(route).path);
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

class RouteFactory extends ArgumentRouteFactory<RouteArgs> {
  RouteFactory(String path)
      : super(path, const ArgumentsFactory(RouteArgs.fromJson));

  RouteWithArguments<RouteArgs> call(String id) {
    return build(RouteArgs(id));
  }
}

class RouteFactory2 extends ArgumentRouteFactory<RouteArgs2> {
  RouteFactory2(String path)
      : super(path, const ArgumentsFactory(RouteArgs2.fromJson));

  RouteWithArguments<RouteArgs2> call(String id, String id2) {
    return build(RouteArgs2(id, id2));
  }
}

class RouteFactory3 extends ArgumentRouteFactory<RouteArgs3> {
  RouteFactory3(String path)
      : super(path, const ArgumentsFactory(RouteArgs3.fromJson));

  RouteWithArguments<RouteArgs3> call(
    String id,
    String id2,
    String id3,
  ) {
    return build(RouteArgs3(id, id2, id3));
  }
}

class RouteFactory4 extends ArgumentRouteFactory<RouteArgs4> {
  RouteFactory4(String path)
      : super(path, const ArgumentsFactory(RouteArgs4.fromJson));

  RouteWithArguments<RouteArgs4> call(
    String id,
    String id2,
    String id3,
    String id4,
  ) {
    return build(RouteArgs4(id, id2, id3, id4));
  }
}
