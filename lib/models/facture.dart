enum FactureStatut { unpaid, paid }

class Facture {
  final String reference;
  final String walletCode;
  final String serviceName;
  final num montant;
  final String devise;
  final FactureStatut statut;
  final String periode;

  const Facture({
    required this.reference,
    required this.walletCode,
    required this.serviceName,
    required this.montant,
    required this.devise,
    required this.statut,
    required this.periode,
  });

  bool get isUnpaid => statut == FactureStatut.unpaid;

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      reference: json['reference'] as String? ?? '',
      walletCode: json['walletCode'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      montant: json['montant'] as num? ?? 0,
      devise: json['devise'] as String? ?? 'XOF',
      statut:
          json['statut'] == 'PAID' ? FactureStatut.paid : FactureStatut.unpaid,
      periode: json['periode'] as String? ?? '',
    );
  }
}
