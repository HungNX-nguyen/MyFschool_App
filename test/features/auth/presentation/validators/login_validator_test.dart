import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/auth/presentation/validators/login_validator.dart';

void main() {
  group('LoginValidator.validateIdentifier', () {
    test('rejects an empty identifier', () {
      expect(LoginValidator.validateIdentifier(''), isNotNull);
      expect(LoginValidator.validateIdentifier('   '), isNotNull);
    });

    test('accepts a phone number', () {
      expect(LoginValidator.validateIdentifier('0987654321'), isNull);
    });

    test('accepts an internal student username', () {
      expect(LoginValidator.validateIdentifier('anhnvhs12345'), isNull);
    });

    test('rejects whitespace and unsupported characters', () {
      expect(LoginValidator.validateIdentifier('student name'), isNotNull);
      expect(LoginValidator.validateIdentifier('student@school'), isNotNull);
    });
  });

  group('LoginValidator.validatePassword', () {
    test('rejects an empty password', () {
      expect(LoginValidator.validatePassword(''), isNotNull);
    });

    test('rejects a password shorter than six characters', () {
      expect(LoginValidator.validatePassword('12345'), isNotNull);
    });

    test('accepts a password with at least six characters', () {
      expect(LoginValidator.validatePassword('123456'), isNull);
    });
  });
}
