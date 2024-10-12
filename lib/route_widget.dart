part of route_builder;

abstract class RouteWidget extends Widget {
  const RouteWidget({super.key});

  Route get route;
}

class StatelessRoute extends StatelessWidget implements RouteWidget {
  final Route _route;
  final Widget? child;

  const StatelessRoute({
    super.key,
    required Route route,
    this.child,
  }) : _route = route;

  @override
  Route get route {
    return _route;
  }

  @override
  build(context) {
    return child ?? const SizedBox.shrink();
  }
}

abstract class StatefulRoute extends StatefulWidget implements RouteWidget {
  final Route _route;

  const StatefulRoute({
    super.key,
    required Route route,
  }) : _route = route;

  @override
  Route get route {
    return _route;
  }
}
