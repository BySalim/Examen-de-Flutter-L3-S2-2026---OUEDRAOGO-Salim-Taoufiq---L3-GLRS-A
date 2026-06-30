import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  static String get host {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static const String _api = '/api';

  static String wallets() => '$host$_api/wallets';

  static String walletsPaged(int page, int size) =>
      '$host$_api/wallets?page=$page&size=$size';

  static String walletByPhone(String phone) => '$host$_api/wallets/$phone';

  static String balance(String phone) => '$host$_api/wallets/$phone/balance';

  static String deposit(int walletId) => '$host$_api/wallets/$walletId/deposit';

  static String withdraw() => '$host$_api/wallets/withdraw';

  static String transfer() => '$host$_api/wallets/transfer';

  static String pay() => '$host$_api/wallets/pay';

  static String payFactures() => '$host$_api/wallets/pay-factures';

  static String transactions(String phone) =>
      '$host$_api/wallets/$phone/transactions';

  static String facturesCurrent(String walletCode, {String? unite}) {
    final base = '$host$_api/external/factures/$walletCode/current';
    return unite == null ? base : '$base?unite=$unite';
  }

  static String facturesPeriode(
    String walletCode,
    String debut,
    String fin, {
    String? unite,
  }) {
    final query = StringBuffer('debut=$debut&fin=$fin');
    if (unite != null) query.write('&unite=$unite');
    return '$host$_api/external/factures/$walletCode/periode?$query';
  }
}
