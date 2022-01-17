## Route Builder

A Flutter navigation utility package for building and matching routes by path, query parameters and arguments.

### Building route names

Flutter supports specifying route names when performing navigation events:

```dart
Navigator.of(context).pushNamed('/location');
```

This navigation action will update the URI path on Flutter web to `/location`. We can similarly update the path for anonymous routes by specifying a route settings object:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    settings: RouteSettings('/location'),
    builder: (BuildContext context) {
      return child;
    },
  )
);
```

Updating the URI in this way becomes more challenging when we need to introduce dynamic arguments to route names such as in the following example where we're viewing a message from an employee:

```dart
final employeeId = uuid();
final messageId = uuid();

Navigator.of(context).push(
  MaterialPageRoute(
    settings: RouteSettings('/employee/$employeeId/messages/$messageId'),
    builder: (BuildContext context) {
      return ViewEmployeeMessage();
    },
  )
);
```

We want to make sure that we're always formatting our route names correctly across all the places in our app where we navigate to `ViewEmployeeMessage`. That's where the `route_builder` package comes in. Route builder allows you to create and match routes by path, query parameters and arguments.

Here is an example where we define some routes for managing employee messages using route builder:

```dart
import 'package:route_builder/route_builder.dart';

class EmployeeMessageArguments extends Arguments {
  final String employeeId;
  final String messageId;

  EmployeeMessageArguments({
    required this.employeeId,
    required this.messageId,
  });

  @override
  toJson() {
    return {
      "employeeId": employeeId,
      "messageId": messageId,
    };
  }
}

class EmployeeMessageArgsFactory extends ArgumentsFactory<EmployeeMessageArguments> {
  @override
  fromJson(json) {
    return EmployeeMessageArguments(
      employeeId: employeeId,
      messageId: messageId
    );
  }
}

class Routes {
  static final viewEmployeeMessage = RouteFactory<EmployeeMessageArguments>(
    '/employee/{employeeId}/messages/{employeeMessage}',
    argsFactory: EmployeeMessageArgsFactory(),
  );

  static final updateEmployeeMessage = RouteFactory<EmployeeMessageArguments>(
    '/employee/{employeeId}/messages/{employeeMessage}/update',
    argsFactory: EmployeeMessageArgsFactory(),
  );

  static final deleteEmployeeMessage = RouteFactory<EmployeeMessageArguments>(
    '/employee/{employeeId}/messages/{employeeMessage}/delete',
    argsFactory: EmployeeMessageArgsFactory(),
  );
}
```

The next time we need to navigate view an employee message, we can then call our route builder with our type-safe arguments:

```dart
final employeeId = uuid();
final messageId = uuid();

Navigator.of(context).push(
  MaterialPageRoute(
    settings: Routes.viewEmployeeMessage(
      EmployeeMessageArguments(
        employeeId: employeeId,
        messageId: messageId,
      ),
    ).settings,
    builder: (BuildContext context) {
      return ViewEmployeeMessage(
        employeeId: employeeId,
        messageId: messageId,
      );
    },
  )
);
```

To create a new employee message, we can define another route that uses an `EmployeeArguments` class:

```dart
import 'package:route_builder/route_builder.dart';

class EmployeeArguments extends Arguments {
  final String employeeId;

  EmployeeMessageArguments({
    required this.employeeId,
  });

  @override
  toJson() {
    return {
      "employeeId": employeeId,
    };
  }
}

class EmployeeArgsFactory extends ArgumentsFactory<EmployeeArguments> {
  @override
  fromJson(json) {
    return EmployeeArguments(
      employeeId: employeeId,
      messageId: messageId
    );
  }
}

class Routes {
  ...

  static final createEmployeeMessage = RouteFactory<EmployeeArguments>(
    '/employee/{employeeId}/messages/create',
    argsFactory: EmployeeArgsFactory(),
  );

  // Routes that have no arguments can simply be specified with the Route class:
  static final viewEmployees = Route('/employees'); 
}
```

The main benefits of using this approach for building routes are reusability and type safety. While it introduces some boilerplate, where this approach shines is when we later need to match routes.

## Matching route names

When a user navigates to a particular route on Flutter web, the [onGenerateRoute](https://api.flutter.dev/flutter/material/MaterialApp/onGenerateRoute.html) API can be used to match the URI with a particular widget.

```dart
MaterialApp(
  title: 'MyApp',
  onGenerateRoute: (RouteSettings settings) {
    final name = settings.name;

    if (Routes.viewEmployeeMessage.match(name)) {
      final route = Routes.viewEmployeeMessage.parse(name)!;
      final args = route.arguments;

      return MaterialPageRoute(
        settings: route.settings,
        builder: (BuildContext context) {
          return ViewEmployeeMessage(
            employeeId: args.employeeId,
            messageId: args.messageId,
          );
        },
      );
    }
  },
);
```

The `match` API matches routes by path and query parameters. The `parse` API can then be used to construct a route object with its arguments and pass them to the widget.

## Matching query parameters

Routes can be constructed with query parameters both with and without a path:

```dart
class Routes {
  static final absoluteViewUserModal = Route('/user?modal=viewUser');
  static final relativeViewUserModal = Route('?modal=viewUser');
}
```

The first route with an absolute path will build and match a URI at the `/user` path, while the second route will build and match routes relative to the current path.

```dart
absoluteViewUserModal.match('/user?modal=viewUser'); // true
absoluteViewUserModal.match('?modal=viewUser'); // false

relativeViewUserModal.match('/user?modal=viewUser'); // true
relativeViewUserModal.match('?modal=viewUser'); // true

// By default excess parameters will still match.
relativeViewUserModal.match('?modal=viewUser&otherParam=true'); // true

// Specify `strictQueryParams` if exact query parameter matching is required
Route('?modal=viewUser', strictQueryParams: true).match('?modal=viewUser&otherParam=true'); // false
```

## Matching arguments

An arguments object can require the presence of certain fields in order to successfully match:

```dart
class EmployeeMessageArguments extends Arguments {
  final String employeeId;
  final String messageId;

  EmployeeMessageArguments({
    required this.employeeId,
    required this.messageId,
  }): super(requiredArgs: ['employeeId', 'messageId']);

  @override
  toJson() {
    return {
      "employeeId": employeeId,
      "messageId": messageId,
    };
  }
}

class EmployeeMessageArgsFactory extends ArgumentsFactory<EmployeeMessageArguments> {
  @override
  fromJson(json) {
    return EmployeeMessageArguments(
      employeeId: employeeId,
      messageId: messageId
    );
  }
}

class Routes {
  ...

  static final viewEmployeeMessage = RouteFactory<EmployeeMessageArguments>(
    '/employee/{employeeId}/messages/{employeeMessage}',
    argsFactory: EmployeeMessageArgsFactory(),
  );

  static final viewEmployeeMessageModal = RouteFactory<EmployeeMessageArguments>(
    '?modal=viewEmployeeMessage',
    argsFactory: EmployeeMessageArgsFactory(),
  );
}
```

These fields can be matched by either the argument paths or the query parameters:

```dart
viewEmployeeMessage.match('/employee/1/messages/1'); // true
viewEmployeeMessage.match('/?modal=viewEmployeeMessage&employeeId=1&messageId=1'); // true
viewEmployeeMessage.match('/?modal=viewEmployeeMessage&employeeId=1'); // false
```


