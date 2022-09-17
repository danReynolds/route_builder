import 'package:route_builder/arguments.dart';
import 'package:route_builder/arguments_factory.dart';

/// A path arguments parser and builder for parsing arguments from a given path
/// matching the arguments format:
/// /{arg1}/.../{arg2}
/// and building a path of the given format from a set of args.
class PathArguments<Y extends Arguments, T extends ArgumentsFactory<Y>> {
  String pathFormat;
  late RegExp _pathParser;

  final _pathArgRegex = RegExp('{(.*?)}');
  final _buildArgFragment = "[\\w\\d-]+?";
  final List<String> argsList = [];

  PathArguments(this.pathFormat) {
    _pathParser = _buildParser(pathFormat);
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
        "(?<$argName>$_buildArgFragment)",
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

  String buildPath(Map<String, String?> argsJson) {
    String path = pathFormat;

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
