class BalanceResponse {
  final String phoneNumber;
  final num balance;
  final String currency;

  const BalanceResponse({
    required this.phoneNumber,
    required this.balance,
    required this.currency,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      balance: json['balance'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
    );
  }
}

class TransferResponse {
  final String senderPhone;
  final String receiverPhone;
  final num amount;
  final num senderBalanceAfter;
  final num receiverBalanceAfter;
  final String currency;

  const TransferResponse({
    required this.senderPhone,
    required this.receiverPhone,
    required this.amount,
    required this.senderBalanceAfter,
    required this.receiverBalanceAfter,
    required this.currency,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      senderPhone: json['senderPhone'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      senderBalanceAfter: json['senderBalanceAfter'] as num? ?? 0,
      receiverBalanceAfter: json['receiverBalanceAfter'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
    );
  }
}

class PaymentResponse {
  final String phoneNumber;
  final String serviceName;
  final List<String> paidFactures;
  final num totalPaid;
  final num balanceAfter;
  final String currency;

  const PaymentResponse({
    required this.phoneNumber,
    required this.serviceName,
    required this.paidFactures,
    required this.totalPaid,
    required this.balanceAfter,
    required this.currency,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      paidFactures: ((json['paidFactures'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      totalPaid: json['totalPaid'] as num? ?? 0,
      balanceAfter: json['balanceAfter'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
    );
  }
}
