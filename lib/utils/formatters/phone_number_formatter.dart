class TPhoneNumberFormatter {
  static String removeCountryCodePrefix(String phoneNumber) {
    // Remove any whitespace and the '+' prefix if present
    return phoneNumber.trim().replaceFirst(RegExp(r'^\+'), '');
  }
}
