class Currency {
  final int id;
  final int walletTypeId;
  final String countryCode;
  final String name;
  final String description;
  final double availableBalance;
  final String code;

  Currency({
    required this.id,
    required this.walletTypeId,
    required this.countryCode,
    required this.name,
    required this.description,
    required this.availableBalance,
    required this.code,
  });
}
