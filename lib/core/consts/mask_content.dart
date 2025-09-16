String maskString(String input) {
  if (input.isEmpty) {
    return input;
  }
  
  if (input.contains('@')) {
    return _maskEmail(input);
  }
  
  if (RegExp(r'^\+?[0-9]{10,15}$').hasMatch(input)) {
    return _maskPhoneNumber(input);
  }
  
  return _maskPhoneNumber(input);
}

String _maskEmail(String email) {
  int atIndex = email.indexOf('@');
  if (atIndex == -1) return email;

  String localPart = email.substring(0, atIndex);
  String domainPart = email.substring(atIndex);

  String maskedLocalPart = 
      localPart.substring(0, localPart.length > 2 ? 3 : 1) +
      "*" * (localPart.length - (localPart.length > 2 ? 3 : 1));

  return maskedLocalPart + domainPart;
}

String _maskPhoneNumber(String number) {
  String cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');
  
  if (cleanNumber.length < 4) return number;
  
  String firstPart = cleanNumber.substring(0, 3);
  String lastPart = cleanNumber.substring(cleanNumber.length - 3);
  String maskedPart = '*' * (cleanNumber.length - 6);
  
  return firstPart + maskedPart + lastPart;
}

