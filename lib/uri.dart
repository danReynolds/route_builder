extension UriExtensions on Uri {
  Uri mergeQueryParams(Map<String, String?> json) {
    return replace(
      queryParameters: {
        ...queryParameters,
        ...json,
      },
    );
  }

  String get pathWithQuery {
    if (query.isEmpty) {
      return path;
    }

    return "$path?$query";
  }
}
