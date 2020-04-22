class Result<T> {
  final T data;
  final String error;
  bool get hasError => error.isNotEmpty;

  Result.error(this.error, [bool printError = true]) : this.data = null {
    if (printError) print('Result.error: $error');
  }
  Result.data(this.data) : this.error = '';
}
