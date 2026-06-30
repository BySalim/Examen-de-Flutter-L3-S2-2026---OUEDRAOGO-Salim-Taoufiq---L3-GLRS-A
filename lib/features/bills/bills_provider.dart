import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/view_status.dart';
import '../../models/facture.dart';
import '../../models/responses.dart';
import '../auth/session_provider.dart';

class BillsProvider extends ChangeNotifier {
  final ApiClient _api;
  final SessionProvider _session;

  BillsProvider(this._api, this._session);

  ViewStatus _status = ViewStatus.idle;
  String? _error;
  List<Facture> _all = const [];
  final Set<String> _selected = {};
  String? _filter;

  num _lastPaidTotal = 0;
  int _lastPaidCount = 0;
  String? _paymentError;

  ViewStatus get status => _status;
  String? get error => _error;
  String? get filter => _filter;
  Set<String> get selected => _selected;
  num get lastPaidTotal => _lastPaidTotal;
  int get lastPaidCount => _lastPaidCount;
  String? get paymentError => _paymentError;

  List<String> get availableServices {
    final services = _all.map((f) => f.serviceName).toSet().toList()..sort();
    return services;
  }

  List<Facture> get factures {
    if (_filter == null) return _all;
    return _all.where((f) => f.serviceName == _filter).toList(growable: false);
  }

  num get selectedTotal => _all
      .where((f) => _selected.contains(f.reference))
      .fold<num>(0, (sum, f) => sum + f.montant);

  bool isSelected(String reference) => _selected.contains(reference);

  Future<void> load() async {
    _status = ViewStatus.loading;
    notifyListeners();
    try {
      final data =
          await _api.get(ApiConstants.facturesCurrent(_session.walletCode));
      _all = (data as List)
          .map((e) => Facture.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      _selected.removeWhere(
          (ref) => !_all.any((f) => f.reference == ref));
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

  void setFilter(String? service) {
    _filter = service;
    notifyListeners();
  }

  void toggle(String reference) {
    if (!_selected.add(reference)) _selected.remove(reference);
    notifyListeners();
  }

  Future<bool> paySelected() async {
    final chosen =
        _all.where((f) => _selected.contains(f.reference)).toList();
    if (chosen.isEmpty) return false;

    final byService = <String, List<String>>{};
    for (final facture in chosen) {
      (byService[facture.serviceName] ??= []).add(facture.reference);
    }

    final paid = <String>[];
    num total = 0;
    num? lastBalance;

    try {
      for (final entry in byService.entries) {
        final json = await _api.post(ApiConstants.payFactures(), {
          'phoneNumber': _session.phone,
          'serviceName': entry.key,
          'factureReferences': entry.value,
        });
        final response = PaymentResponse.fromJson(json as Map<String, dynamic>);
        paid.addAll(response.paidFactures);
        total += response.totalPaid;
        lastBalance = response.balanceAfter;
      }
      if (lastBalance != null) _session.updateBalance(lastBalance);
      _lastPaidTotal = total;
      _lastPaidCount = paid.length;
      _paymentError = null;
      await load();
      return true;
    } on ApiException catch (e) {
      if (paid.isNotEmpty) {
        // Certaines factures ont déjà été débitées côté serveur : on resynchronise.
        _lastPaidTotal = total;
        _lastPaidCount = paid.length;
        if (lastBalance != null) _session.updateBalance(lastBalance);
        _paymentError =
            'Certaines factures ont été payées, d\'autres ont échoué : ${e.message}';
        await load();
      } else {
        _paymentError = e.message;
      }
      return false;
    }
  }
}
