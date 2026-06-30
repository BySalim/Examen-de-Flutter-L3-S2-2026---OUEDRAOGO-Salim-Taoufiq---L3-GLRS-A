import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/view_status.dart';
import '../../models/wallet_transaction.dart';
import '../auth/session_provider.dart';

class HistoryProvider extends ChangeNotifier {
  final ApiClient _api;
  final SessionProvider _session;

  HistoryProvider(this._api, this._session);

  ViewStatus _status = ViewStatus.idle;
  String? _error;
  List<WalletTransaction> _all = const [];
  TransactionType? _filter;

  ViewStatus get status => _status;
  String? get error => _error;
  TransactionType? get filter => _filter;

  List<WalletTransaction> get transactions {
    if (_filter == null) return _all;
    return _all.where((t) => t.type == _filter).toList(growable: false);
  }

  Future<void> load() async {
    _status = ViewStatus.loading;
    notifyListeners();
    try {
      final data = await _api.get(ApiConstants.transactions(_session.phone));
      _all = (data as List)
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  void setFilter(TransactionType? type) {
    _filter = type;
    notifyListeners();
  }
}
