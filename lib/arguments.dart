part of route_builder;

abstract class Arguments {
  const Arguments();

  Map<String, String?> toJson();
}

class ArgumentsFactory<T> {
  final T Function(Map<String, String> json) fromJson;
  final List<String> requiredArgs;

  const ArgumentsFactory(
    this.fromJson, {
    this.requiredArgs = const [],
  });
}

class RouteArgs extends Arguments {
  final String id;

  const RouteArgs(this.id);

  RouteArgs.fromJson(Map<String, String> json) : id = json['id']!;

  @override
  toJson() {
    return {
      "id": id,
    };
  }
}

class RouteArgs2 extends Arguments {
  final String id;
  final String id2;

  RouteArgs2(this.id, this.id2);

  RouteArgs2.fromJson(Map<String, String> json)
      : id = json['id']!,
        id2 = json['id2']!;

  @override
  toJson() {
    return {
      "id": id,
      "id2": id2,
    };
  }
}

class RouteArgs3 extends Arguments {
  final String id;
  final String id2;
  final String id3;

  RouteArgs3(this.id, this.id2, this.id3);

  RouteArgs3.fromJson(Map<String, String> json)
      : id = json['id']!,
        id2 = json['id2']!,
        id3 = json['id3']!;

  @override
  toJson() {
    return {
      "id": id,
      "id2": id2,
      "id3": id3,
    };
  }
}

class RouteArgs4 extends Arguments {
  final String id;
  final String id2;
  final String id3;
  final String id4;

  RouteArgs4(this.id, this.id2, this.id3, this.id4);

  RouteArgs4.fromJson(Map<String, String> json)
      : id = json['id']!,
        id2 = json['id2']!,
        id3 = json['id3']!,
        id4 = json['id4']!;

  @override
  toJson() {
    return {
      "id": id,
      "id2": id2,
      "id3": id3,
      "id4": id4,
    };
  }
}
