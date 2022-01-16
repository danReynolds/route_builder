abstract class ArgumentsFactory<T> {
  T fromJson(Map<String, String> json);

  List<String> requiredArgs;

  ArgumentsFactory({this.requiredArgs = const []});
}
