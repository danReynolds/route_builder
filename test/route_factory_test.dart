import 'package:flutter_test/flutter_test.dart';
import 'package:route_builder/route_builder.dart';

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

class OptionalTestArgumentsFactory extends ArgumentsFactory<TestArguments> {
  OptionalTestArgumentsFactory();

  @override
  fromJson(json) {
    return TestArguments(param: json['param']);
  }
}

void main() {
  group('parse', () {
    late RouteFactory<TestArguments> factory;

    setUp(() {
      factory =
          RouteFactory('/test/{param}', argsFactory: TestArgumentsFactory());
    });

    group('with a matching path', () {
      test('should build a route', () {
        final factory =
            RouteFactory('/test/{param}', argsFactory: TestArgumentsFactory());
        final route = factory.parse('/test/thing')!;

        expect(route.name, '/test/thing');
        expect(route.arguments.param, 'thing');
      });

      group('with query params', () {
        setUp(() {
          factory = RouteFactory(
            '/test/{param}?test&test2=true',
            argsFactory: TestArgumentsFactory(),
          );
        });

        group('with matching query params', () {
          test('should build the route with query params', () {
            final route = factory.parse('/test/thing?test&test2=true');
            expect(route?.name, '/test/thing?test&test2=true');
          });
        });

        group('with unmatched query params', () {
          test('should return null', () {
            final route = factory.parse('/test/thing?test');
            expect(route, null);
          });
        });
      });
    });

    group('with an unmatched path', () {
      test('should return null', () {
        final route = factory.parse('/test');
        expect(route, null);
      });
    });

    group('with no path', () {
      setUp(() {
        factory = RouteFactory(
          '?test',
          argsFactory: TestArgumentsFactory(),
        );
      });

      test('should build the route using the current path', () {
        final route = factory.parse('?test&param=true');
        expect(route?.name, '${Uri.base.path}?test&param=true');
      });
    });
  });

  group('match', () {
    late RouteFactory<TestArguments> factory;

    setUp(() {
      factory = RouteFactory(
        '/{param}/test',
        argsFactory: TestArgumentsFactory(),
      );
    });

    group('with a matching path', () {
      test('should return true', () {
        expect(factory.match('/value/test'), true);
      });

      group('with query params', () {
        setUp(() {
          factory = RouteFactory(
            '/{param}/test?thing',
            argsFactory: TestArgumentsFactory(),
          );
        });

        test('should return true for matching query params', () {
          expect(factory.match('/value/test?thing'), true);
        });
      });
    });

    group('with no matching path', () {
      test('should return false', () {
        expect(factory.match('/value/other'), false);
      });
    });

    group('with no path', () {
      setUp(() {
        factory = RouteFactory(
          '?param=true',
          argsFactory: TestArgumentsFactory(),
        );
      });

      test('should match query params', () {
        expect(factory.match('?param=true'), true);
      });

      group('with strict query params', () {
        setUp(() {
          factory = RouteFactory(
            '?param=true',
            argsFactory: TestArgumentsFactory(),
            strictQueryParams: true,
          );
        });

        test('should match exact query params', () {
          expect(factory.match('?param=true'), true);
        });

        test('should not match additional query params', () {
          expect(factory.match('?param=true&thing2=false'), false);
        });
      });
    });

    group('with missing required arguments', () {
      setUp(() {
        factory = RouteFactory(
          '?thing=true',
          argsFactory: TestArgumentsFactory(),
        );
      });

      test('should return false', () {
        expect(factory.match('?thing=true'), false);
      });
    });

    group('with missing optional arguments', () {
      setUp(() {
        factory = RouteFactory(
          '?thing=true',
          argsFactory: OptionalTestArgumentsFactory(),
        );
      });

      test('should return true', () {
        expect(factory.match('?thing=true'), true);
      });
    });
  });

  group('call', () {
    test('should build a route with the given args', () {
      final factory = RouteFactory(
        '/{param}/test',
        argsFactory: TestArgumentsFactory(),
      );

      expect(factory(TestArguments(param: 'value')).name, '/value/test');
    });

    test('should preserve query params', () {
      final factory = RouteFactory(
        '/{param}/test?thing=2',
        argsFactory: TestArgumentsFactory(),
      );

      expect(
          factory(TestArguments(param: 'value')).name, '/value/test?thing=2');
    });
  });
}
