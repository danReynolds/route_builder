import 'package:flutter_test/flutter_test.dart';
import 'package:route_builder/arguments.dart';
import 'package:route_builder/arguments_factory.dart';
import 'package:route_builder/routes.dart';

class TestArguments extends Arguments {
  final String? param;

  TestArguments({
    required this.param,
  });

  @override
  toJson() {
    return {
      "param": param,
    };
  }
}

class TestArgumentsFactory extends ArgumentsFactory<TestArguments> {
  TestArgumentsFactory() : super(requiredArgs: ['param']);

  @override
  fromJson(json) {
    return TestArguments(param: json['param']!);
  }
}

void main() {
  setUp(() {
    Routes.clear();
  });

  group('register', () {
    test('should register a route', () {
      final route = Routes.register('/test');
      expect(route.name, '/test');
    });
  });

  group('registerFactory', () {
    test('should register a route factory', () {
      final route = Routes.registerFactory<TestArguments>(
        '/test',
        argsFactory: TestArgumentsFactory(),
      );
      expect(route.uri.toString(), '/test');
    });
  });

  group('firstMatch', () {
    test('should find matching routes', () {
      Routes.register('/test');
      expect(Routes.firstMatch('/test') != null, true);
    });

    test('should not find unmatched routes', () {
      Routes.register('/test');
      expect(Routes.firstMatch('/test2'), null);
    });
  });

  group('allMatches', () {
    test('should find all matching routes', () {
      Routes.register('/test?thing=true');
      Routes.register('/test?thing=true&thing2=true');
      Routes.register('/test?thing=true&thing2=true&thing3=true');

      expect(Routes.allMatches('/test?thing=true&thing2=true').length, 2);
    });
  });
}
