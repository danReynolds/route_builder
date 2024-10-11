## Route Builder

Simple routes for Flutter apps.

```dart
import 'package:route_builder/route_builder.dart';

class Routes {
  static final users = Route('/users');
  static final editUser = RouteFactory('/user/{id}/edit');
}

class UsersPage extends StatelessRoute {
  UsersPage() : super(route: Routes.users);
}

class EditUserPage extends StatelessRoute {
  final String userId;

  UserPage({
    required this.userId,
  }) : super(route: Routes.editUser(userId));
}
```

## Matching routes

```dart
final routeStr = '/users';
final editRouteStr = '/user/1/edit';

print(Routes.users.match(routeStr)); // true
print(Routes.editUser.match(routeStr)); // false

print(Routes.editUser.match(editRouteStr)); // true

final Route editRoute = Routes.editUser.parse(editRouteStr);
print(editRoute.id); // 1
```

## Navigation

Flutter supports specifying route names when performing navigation events:

```dart
Navigator.of(context).pushNamed(Routes.users.name);
```

We can similarly update the path for anonymous routes by specifying a route settings object:

```dart
final userId = '1';

Navigator.of(context).push(
  MaterialPageRoute(
    settings: Routes.editUser(userId),
    builder: (BuildContext context) {
      return EditUserPage(userId: userId);
    },
  )
);
```