import 'dart:convert';

class Result<T> {
  final T data;
  final String error;
  bool get hasError => error.isNotEmpty;

  Result.error(this.error) : this.data = null;
  Result.data(this.data) : this.error = '';
}
