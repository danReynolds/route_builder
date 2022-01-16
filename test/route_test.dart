import 'package:flutter_test/flutter_test.dart';
import 'package:route_builder/route_builder.dart';

void main() {
  group('name', () {
    group('with a path', () {
      test('should return the absolute path', () {
        expect(Route('/').name, '/');
      });
    });

    group('with only query params', () {
      test('should return a path relative to the current base', () {
        expect(Route('?test').name, '${Uri.base.path}?test');
      });
    });
  });

  group('settings', () {
    test('should return a RouteSettings for the given name', () {
      expect(Route('/test').settings.name, '/test');
    });
  });

  group('match', () {
    test('should return true for matching paths', () {
      expect(Route('/test').match('/test'), true);
    });

    test('should return false for non-matching paths', () {
      expect(Route('/test').match('/test2'), false);
    });

    group('match query params', () {
      test('should return true for matching query params', () {
        expect(Route('?test').match('?test'), true);
      });

      test('should return false for missing query params', () {
        expect(Route('?test').match('?test2'), false);
      });

      test('should not exact match query params by default', () {
        expect(Route('?test').match('?test&test2'), true);
      });

      test('should exact match query params when specified', () {
        expect(
          Route('?test', strictQueryParams: true).match('?test&thing=2'),
          false,
        );
      });
    });

    test('return true for matching paths and matching query params', () {
      expect(Route('/test?param').match('/test?param'), true);
    });
  });

  group('isAuthorized', () {
    bool isAuthorized([_]) {
      return true;
    }

    bool isNotAuthorized([_]) {
      return false;
    }

    test('should return true by default', () {
      expect(Route('/').isAuthorized(), true);
    });

    test('should return true when it satisifies the auth function', () {
      expect(Route('/', authorize: isAuthorized).isAuthorized(), true);
    });

    test('should return false when it does not satisify the auth function', () {
      expect(Route('/', authorize: isNotAuthorized).isAuthorized(), false);
    });
  });
}
