## Route Builder

Simple routes for Flutter apps.

```dart
import 'package:route_builder/route_builder.dart';

class Routes {
  static final users = Route('/users');
  static final editUser = RouteFactory('/user/{id}/edit');
  static final viewPost = RouteFactory2('/user/{id}/post/{id2}');
}

print(Routes.users.name); // /users
print(Routes.editUser('1').name); // /user/1
print(Routes.viewPost('1', '2').name); // /user/1/post/2
```

## Matching routes

```dart
final routeStr = '/users';
final editRouteStr = '/user/1/edit';

print(Routes.users.match(routeStr)); // true
print(Routes.editUser.match(routeStr)); // false

print(Routes.editUser.match(editRouteStr)); // true

final Route editRoute = Routes.editUser.parse(editRouteStr)!;
print(editRoute.id); // 1

final Route viewPostRoute = Routes.viewPost.parse('/user/1/post/2')!;
print(viewPostRoute.id); // 1
print(viewPostRoute.id2); // 2
```

## Custom factories

By default, the route factories `RouteFactory`, `RouteFactory2`, `RouteFactory3`..., extract parameters
to properties `id`, `id2`, `id3` out of convenience.

If custom parameter naming is preferred, you can create a custom factory:

```dart
class UserPostArguments extends Arguments {
  final String userId;
  final String postId;

  const UserPostArguments({
    required this.userId,
    required this.postId,
  });

  UserPostArguments.fromJson(Map<String, String> json) :
    userId = json['userId']!, postId = json['postId']!;

  @override
  toJson() {
    return {
      "userId": userId,
      "postId": postId,
    };
  }
}

class UserPostRouteFactory extends ArgumentRouteFactory<UserPostArguments> {
  RouteFactory(String path): super(path, UserPostArguments.fromJson);

  RouteWithArguments<UserPostArguments> call({
    required String userId,
    required String postId,
  }) {
    return build(UserPostArguments(userId: userId, postId: postId));
  }
}

final viewPost = UserPostRouteFactory('/user/{userId}/post/{postId}');
final viewPostRoute = viewPost(userId: '1', postId: '2');

print(viewPostRoute.userId); // 1
print(viewPostRoute.postId); // 2
```

## Navigation

Flutter supports specifying route names when performing navigation events:

```dart
Navigator.of(context).pushNamed(Routes.users.name);
```

Or by specifying a `RouteSettings` object:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    settings: RouteSettings(name: Routes.users.name),
    builder: (BuildContext context) {
      return ViewUsersPage();
    },
  )
);
```

You can also access the `RouteSettings` directly from the route:


```dart
Navigator.of(context).push(
  MaterialPageRoute(
    settings: Routes.users.settings,
    builder: (BuildContext context) {
      return ViewUsersPage();
    },
  )
);
```
