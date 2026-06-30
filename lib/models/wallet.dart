class Wallet {
  final int id;
  final String phoneNumber;
  final String email;
  final num balance;
  final String code;
  final String currency;
  final DateTime? createdAt;

  const Wallet({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.balance,
    required this.code,
    required this.currency,
    this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      balance: json['balance'] as num? ?? 0,
      code: json['code'] as String? ?? '',
      currency: json['currency'] as String? ?? 'XOF',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
