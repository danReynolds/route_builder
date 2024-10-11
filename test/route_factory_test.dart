import 'package:flutter_test/flutter_test.dart';
import 'package:route_builder/route_builder.dart';

class CustomArguments extends Arguments {
  final String? param;

  CustomArguments({
    required this.param,
  });

  @override
  toJson() {
    return {
      "param": param,
    };
  }
}

class CustomArgumentsFactory extends ArgumentsFactory<CustomArguments> {
  CustomArgumentsFactory()
      : super(
          (json) => CustomArguments(param: json['param']!),
          requiredArgs: ['param'],
        );
}

class OptionalCustomArgumentsFactory extends ArgumentsFactory<CustomArguments> {
  OptionalCustomArgumentsFactory()
      : super(
          (json) => CustomArguments(param: json['param']),
        );
}

void main() {
  group(
    'ArgumentRouteFactory',
    () {
      group('parse', () {
        late ArgumentRouteFactory<CustomArguments> factory;

        setUp(() {
          factory =
              ArgumentRouteFactory('/test/{param}', CustomArgumentsFactory());
        });

        group('with a matching path', () {
          test('should build a route', () {
            final factory =
                ArgumentRouteFactory('/test/{param}', CustomArgumentsFactory());
            final route = factory.parse('/test/thing')!;

            expect(route.name, '/test/thing');
            expect(route.arguments.param, 'thing');
          });

          group('with query params', () {
            setUp(() {
              factory = ArgumentRouteFactory(
                '/test/{param}?test&test2=true',
                CustomArgumentsFactory(),
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
            factory = ArgumentRouteFactory('?test', CustomArgumentsFactory());
          });

          test('should build the route using the current path', () {
            final route = factory.parse('?test&param=true');
            expect(route?.name, '${Uri.base.path}?test&param=true');
          });
        });
      });

      group('match', () {
        late ArgumentRouteFactory<CustomArguments> factory;

        setUp(() {
          factory =
              ArgumentRouteFactory('/{param}/test', CustomArgumentsFactory());
        });

        group('with a matching path', () {
          test('should return true', () {
            expect(factory.match('/value/test'), true);
          });

          group('with query params', () {
            setUp(() {
              factory = ArgumentRouteFactory(
                '/{param}/test?thing',
                CustomArgumentsFactory(),
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

        group('with an empty path value', () {
          test('should return false', () {
            expect(
              ArgumentRouteFactory(
                '/{param}',
                CustomArgumentsFactory(),
              ).match('/'),
              false,
            );
          });
        });

        group('with no path', () {
          setUp(() {
            factory = ArgumentRouteFactory(
              '?param=true',
              CustomArgumentsFactory(),
            );
          });

          test('should match query params', () {
            expect(factory.match('?param=true'), true);
          });

          group('with strict query params', () {
            setUp(() {
              factory = ArgumentRouteFactory(
                '?param=true',
                CustomArgumentsFactory(),
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
            factory = ArgumentRouteFactory(
              '?thing=true',
              CustomArgumentsFactory(),
            );
          });

          test('should return false', () {
            expect(factory.match('?thing=true'), false);
          });
        });

        group('with missing optional arguments', () {
          setUp(() {
            factory = ArgumentRouteFactory(
              '?thing=true',
              OptionalCustomArgumentsFactory(),
            );
          });

          test('should return true', () {
            expect(factory.match('?thing=true'), true);
          });
        });
      });

      group('build', () {
        test('should build a route with the given args', () {
          final factory = ArgumentRouteFactory(
            '/{param}/test',
            CustomArgumentsFactory(),
          );

          expect(
            factory.build(CustomArguments(param: 'value')).name,
            '/value/test',
          );
        });

        test('should preserve query params', () {
          final factory = ArgumentRouteFactory(
            '/{param}/test?thing=2',
            CustomArgumentsFactory(),
          );

          expect(
            factory.build(CustomArguments(param: 'value')).name,
            '/value/test?thing=2',
          );
        });
      });
    },
  );

  group(
    'RouteFactory',
    () {
      test(
        'Builds routes with the specified parameters',
        () {
          expect(RouteFactory('/users/{id}')('1').name, '/users/1');
          expect(
            RouteFactory2('/users/{id}/posts/{id2}')('1', '2').name,
            '/users/1/posts/2',
          );
          expect(
            RouteFactory3('/users/{id}/posts/{id2}/reactions/{id3}')(
              '1',
              '2',
              '3',
            ).name,
            '/users/1/posts/2/reactions/3',
          );
          expect(
            RouteFactory4(
              '/users/{id}/posts/{id2}/reactions/{id3}/subreactions/{id4}',
            )(
              '1',
              '2',
              '3',
              '4',
            ).name,
            '/users/1/posts/2/reactions/3/subreactions/4',
          );
        },
      );
    },
  );

  group('Route', () {
    test('builds routes', () {
      expect(Route('/users').name, '/users');
    });
  });
}
