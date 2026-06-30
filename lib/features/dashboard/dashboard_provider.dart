import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/view_status.dart';
import '../../models/wallet_transaction.dart';
import '../auth/session_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _api;
  final SessionProvider _session;

  DashboardProvider(this._api, this._session);

  ViewStatus _status = ViewStatus.idle;
  List<WalletTransaction> _transactions = const [];
  String? _error;

  ViewStatus get status => _status;
  String? get error => _error;
  List<WalletTransaction> get recent => _transactions.take(5).toList();

  Future<void> load() async {
    _status = ViewStatus.loading;
    notifyListeners();
    try {
      await _session.refreshBalance();
      final data = await _api.get(ApiConstants.transactions(_session.phone));
      _transactions = (data as List)
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    } catch (_) {
      _error = 'Données illisibles.';
      _status = ViewStatus.error;
    }
    notifyListeners();
  }
}
