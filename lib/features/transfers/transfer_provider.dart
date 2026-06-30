import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/view_status.dart';
import '../../models/responses.dart';
import '../auth/session_provider.dart';

class TransferProvider extends ChangeNotifier {
  final ApiClient _api;
  final SessionProvider _session;

  TransferProvider(this._api, this._session);

  ViewStatus _status = ViewStatus.idle;
  String? _error;
  TransferResponse? _result;

  ViewStatus get status => _status;
  String? get error => _error;
  TransferResponse? get result => _result;

  Future<bool> submit({
    required String receiverPhone,
    required num amount,
  }) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final json = await _api.post(ApiConstants.transfer(), {
        'senderPhone': _session.phone,
        'receiverPhone': receiverPhone,
        'amount': amount,
      });
      _result = TransferResponse.fromJson(json as Map<String, dynamic>);
      _session.updateBalance(_result!.senderBalanceAfter);
      _status = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
      return false;
    }
  }
}
