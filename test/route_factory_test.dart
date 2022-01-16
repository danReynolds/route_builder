import 'package:flutter_test/flutter_test.dart';
import 'package:route_builder/arguments.dart';
import 'package:route_builder/arguments_factory.dart';
import 'package:route_builder/route_builder.dart';

class TestArguments extends Arguments {
  final String param;

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
  group('parse', () {
    late RouteFactory<TestArguments> factory;

    setUp(() {
      factory =
          RouteFactory('/test/{param}', argsFactory: TestArgumentsFactory());
    });

    group('with a matching route', () {
      test('should build a route', () {
        final factory =
            RouteFactory('/test/{param}', argsFactory: TestArgumentsFactory());
        final route = factory.parse('/test/thing')!;

        expect(route.name, '/test/thing');
        expect(route.arguments.param, 'thing');
      });
    });

    group('with an unmatched route', () {
      test('should return null', () {
        final route = factory.parse('/test');
        expect(route, null);
      });
    });
  });
}
