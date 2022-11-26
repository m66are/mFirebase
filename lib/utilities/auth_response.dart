enum ResponseStatus { Success, Error }

extension ParseResponseStatusToString on ResponseStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension ParseStringToResponseStatus on String {
  ResponseStatus toResponseStatus() {
    return ResponseStatus.values
        .firstWhere((e) => e.toShortString().toLowerCase() == toLowerCase());
  }
}

class AuthResponse<T> {
  ResponseStatus status;
  String? errorMessage;
  String? errorCode;
  T? data;

  AuthResponse(
    this.status, {
    this.errorMessage,
    this.errorCode,
    this.data,
  });

  bool get success => status == ResponseStatus.Success;

  factory AuthResponse.fromJson(dynamic json) {
    final ResponseStatus status = json["status"].toString().toResponseStatus();
    final String? errorMessage = json["errorMessage"];
    final String? errorCode = json["errorCode"];
    final dynamic data = json;
    return AuthResponse(
      status,
      errorMessage: errorMessage,
      errorCode: errorCode,
      data: json,
    );
  }

  @override
  String toString() {
    return "AuthResponse : { status: $status , errorCode: $errorCode , errorMessage: $errorMessage , data : $data }";
  }
}
