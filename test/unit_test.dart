import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:badwallet/core/utils/formatters.dart';
import 'package:badwallet/models/facture.dart';
import 'package:badwallet/models/responses.dart';
import 'package:badwallet/models/wallet.dart';
import 'package:badwallet/models/wallet_transaction.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  String normalize(String value) => value.replaceAll(RegExp(r'\s+'), ' ');

  group('Formatters', () {
    test('money formate un montant en XOF', () {
      expect(normalize(Formatters.money(50000)), '50 000 XOF');
    });

    test('phone formate un numéro sénégalais', () {
      expect(Formatters.phone('+221770000003'), '+221 77 000 00 03');
    });
  });

  group('Parsing des modèles', () {
    test('Wallet.fromJson', () {
      final wallet = Wallet.fromJson({
        'id': 3,
        'phoneNumber': '+221770000003',
        'email': 'wallet3@badwallet.sn',
        'balance': 100000.00,
        'code': 'WLT-0000003',
        'currency': 'XOF',
        'createdAt': '2026-06-29T12:00:00Z',
      });
      expect(wallet.code, 'WLT-0000003');
      expect(wallet.balance, 100000.00);
      expect(wallet.createdAt, isNotNull);
    });

    test('WalletTransaction utilise le sens fourni par l\'API', () {
      final tx = WalletTransaction.fromJson({
        'id': 1,
        'type': 'TRANSFER',
        'direction': 'CREDIT',
        'amount': 5000,
        'fee': 0,
        'balanceAfter': 105000,
        'currency': 'XOF',
        'counterpartyPhone': '+221770000002',
        'reference': null,
        'description': 'Transfert recu',
        'createdAt': '2026-06-29T12:00:00Z',
      });
      expect(tx.type, TransactionType.transfer);
      expect(tx.isCredit, isTrue);
      expect(tx.reference, isNull);
    });

    test('Facture.fromJson lit les champs en français', () {
      final facture = Facture.fromJson({
        'reference': 'FAC-ISM-3-4',
        'walletCode': 'WLT-0000003',
        'serviceName': 'ISM',
        'montant': 5000.00,
        'devise': 'XOF',
        'statut': 'UNPAID',
        'periode': '2026-06',
      });
      expect(facture.isUnpaid, isTrue);
      expect(facture.montant, 5000.00);
    });

    test('PaymentResponse.fromJson', () {
      final response = PaymentResponse.fromJson({
        'phoneNumber': '+221770000003',
        'serviceName': 'ISM',
        'paidFactures': ['FAC-ISM-3-4'],
        'totalPaid': 5000,
        'balanceAfter': 95000,
        'currency': 'XOF',
      });
      expect(response.paidFactures, hasLength(1));
      expect(response.totalPaid, 5000);
    });
  });
}
