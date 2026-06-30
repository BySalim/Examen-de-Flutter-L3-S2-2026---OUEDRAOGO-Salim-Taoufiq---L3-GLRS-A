enum ViewStatus { idle, loading, success, error }

extension ViewStatusX on ViewStatus {
  bool get isLoading => this == ViewStatus.loading;
  bool get isError => this == ViewStatus.error;
  bool get isSuccess => this == ViewStatus.success;
}
