import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/view_status.dart';
import '../../models/responses.dart';
import '../../models/wallet.dart';

class SessionProvider extends ChangeNotifier {
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  SessionProvider(this._api, [FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _phoneKey = 'badwallet.phone';

  ViewStatus _status = ViewStatus.idle;
  Wallet? _wallet;
  num? _balance;
  String? _error;
  bool _restoring = true;

  ViewStatus get status => _status;
  Wallet? get wallet => _wallet;
  String? get error => _error;
  bool get restoring => _restoring;
  bool get isAuthenticated => _wallet != null;
  String get phone => _wallet?.phoneNumber ?? '';
  String get walletCode => _wallet?.code ?? '';
  num get balance => _balance ?? _wallet?.balance ?? 0;

  Future<void> restore() async {
    final saved = await _storage.read(key: _phoneKey);
    final tasks = <Future<void>>[
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ];
    if (saved != null && saved.isNotEmpty) {
      tasks.add(_loadSilently(saved));
    }
    await Future.wait(tasks);
    _restoring = false;
    notifyListeners();
  }

  Future<void> _loadSilently(String phone) async {
    try {
      _wallet = await _fetchWallet(phone);
      _balance = _wallet?.balance;
    } catch (_) {
      _wallet = null;
    }
  }

  Future<bool> login(String phone) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final wallet = await _fetchWallet(phone);
      _wallet = wallet;
      _balance = wallet.balance;
      await _storage.write(key: _phoneKey, value: wallet.phoneNumber);
      _status = ViewStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = ViewStatus.error;
      _error = e.isNotFound
          ? 'Aucun compte BadWallet associé à ce numéro.'
          : e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _status = ViewStatus.error;
      _error = 'Données du compte invalides.';
      notifyListeners();
      return false;
    }
  }

  void updateBalance(num value) {
    _balance = value;
    notifyListeners();
  }

  Future<void> refreshBalance() async {
    if (_wallet == null) return;
    try {
      final json = await _api.get(ApiConstants.balance(_wallet!.phoneNumber));
      _balance = BalanceResponse.fromJson(json as Map<String, dynamic>).balance;
      notifyListeners();
    } catch (_) {
      // on garde la dernière valeur connue si le rafraîchissement échoue
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _phoneKey);
    _wallet = null;
    _balance = null;
    _status = ViewStatus.idle;
    notifyListeners();
  }

  Future<Wallet> _fetchWallet(String phone) async {
    final json = await _api.get(ApiConstants.walletByPhone(phone));
    return Wallet.fromJson(json as Map<String, dynamic>);
  }
}
