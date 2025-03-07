/// api Method type enum 지정
enum ApiMethod {
  get,
  post,
  delete,
  put,
  patch;
}

extension ApiMethodExtension on ApiMethod {
  String get type {
    switch (this) {
      case ApiMethod.get:
        return "GET";
      case ApiMethod.post:
        return "POST";
      case ApiMethod.delete:
        return "DELETE";
      case ApiMethod.put:
        return "PUT";
      case ApiMethod.patch:
        return "PATCH";
    }
  }
}
