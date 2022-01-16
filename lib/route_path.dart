import 'package:route_builder/arguments.dart';
import 'package:route_builder/arguments_factory.dart';

class RoutePath<Y extends Arguments, T extends ArgumentsFactory<Y>> {
  String path;
  late RegExp _pathParser;

  final _pathArgRegex = RegExp('\{(.*?)\}');
  final _buildArgFragment = "[\\w\\d-]*?";
  final List<String> argsList = [];

  RoutePath(this.path) {
    _pathParser = _buildParser(path);
  }

  RegExp _buildParser(String path) {
    while (true) {
      final match = _pathArgRegex.firstMatch(path);

      if (match == null) {
        break;
      }

      final argName = match.group(1)!;
      path = path.replaceFirst(
        _pathArgRegex,
        "(\?<$argName>$_buildArgFragment)",
      );

      argsList.add(argName);
    }

    return RegExp("^$path\$");
  }

  bool match(String? path) {
    if (path == null) {
      return false;
    }

    return _pathParser.firstMatch(path) != null;
  }

  String build(Map<String, String> argsJson) {
    String path = "${this.path}";

    while (_pathArgRegex.hasMatch(path)) {
      final argName = _pathArgRegex.firstMatch(path)!.group(1)!;
      path = path.replaceFirst(_pathArgRegex, argsJson[argName]!);
    }

    return path;
  }

  Map<String, String> parseArgs(String? path) {
    if (!match(path)) {
      return {};
    }

    Map<String, String> argsJson = {};
    final argMatches = _pathParser.firstMatch(path!);

    for (String argName in argsList) {
      if (argMatches != null) {
        String matchedGroup = argMatches.namedGroup(argName)!;
        argsJson[argName] = matchedGroup;
      }
    }

    return argsJson;
  }
}
