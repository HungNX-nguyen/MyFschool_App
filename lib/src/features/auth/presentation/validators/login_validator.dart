abstract final class LoginValidator {
  static final RegExp _identifierPattern = RegExp(r'^[a-zA-Z0-9._-]+$');

  static String? validateIdentifier(String? value) {
    final identifier = value?.trim() ?? '';

    if (identifier.isEmpty) {
      return 'Vui lòng nhập số điện thoại hoặc tên đăng nhập';
    }

    if (identifier.length < 3 || identifier.length > 100) {
      return 'Tên đăng nhập phải có từ 3 đến 100 ký tự';
    }

    if (!_identifierPattern.hasMatch(identifier)) {
      return 'Tên đăng nhập chỉ gồm chữ, số, dấu chấm, gạch dưới hoặc gạch ngang';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }
}
