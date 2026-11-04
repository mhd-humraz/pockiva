String formatRupees(int paise, {bool decimals = false}) {
  final rupees = paise / 100;
  if (!decimals && paise % 100 == 0) {
    return '₹${(paise ~/ 100).toString()}';
  }
  return '₹${rupees.toStringAsFixed(2)}';
}

int? parseRupeesToPaise(String value) {
  final amount = double.tryParse(value.trim().replaceAll(',', ''));
  if (amount == null || amount <= 0 || !amount.isFinite) return null;
  return (amount * 100).round();
}
