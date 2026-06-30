enum TransactionType { deposit, withdraw, transfer, payment, unknown }

enum TransactionDirection { credit, debit }

class WalletTransaction {
  final int? id;
  final TransactionType type;
  final TransactionDirection direction;
  final num amount;
  final num fee;
  final num balanceAfter;
  final String currency;
  final String? counterpartyPhone;
  final String? reference;
  final String? description;
  final DateTime? createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.fee,
    required this.balanceAfter,
    required this.currency,
    this.counterpartyPhone,
    this.reference,
    this.description,
    this.createdAt,
  });

  bool get isCredit => direction == TransactionDirection.credit;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: (json['id'] as num?)?.toInt(),
      type: _typeFrom(json['type'] as String?),
      direction: _directionFrom(json['direction'] as String?),
      amount: json['amount'] as num? ?? 0,
      fee: json['fee'] as num? ?? 0,
      balanceAfter: json['balanceAfter'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      counterpartyPhone: json['counterpartyPhone'] as String?,
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  static TransactionType _typeFrom(String? raw) {
    switch (raw) {
      case 'DEPOSIT':
        return TransactionType.deposit;
      case 'WITHDRAW':
        return TransactionType.withdraw;
      case 'TRANSFER':
        return TransactionType.transfer;
      case 'PAYMENT':
        return TransactionType.payment;
      default:
        return TransactionType.unknown;
    }
  }

  static TransactionDirection _directionFrom(String? raw) {
    return raw == 'CREDIT'
        ? TransactionDirection.credit
        : TransactionDirection.debit;
  }
}
