class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    required this.statusCode,
  });

  factory ApiResponse.success({
    required String message,
    T? data,
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    int statusCode = 400,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, {T Function(Map<String, dynamic>)? fromJsonT}) {
    return ApiResponse<T>(
      success: json['success'] ?? (json.containsKey('customer') || json.containsKey('data')),
      message: json['message'] ?? '',
      data: fromJsonT != null && json['customer'] != null 
          ? fromJsonT(json['customer']) 
          : json['data'],
      errors: json['errors'],
      statusCode: 200,
    );
  }
}