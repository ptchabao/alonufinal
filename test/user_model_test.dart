import 'package:alonu_app/core/constants/app_constants.dart';
import 'package:alonu_app/data/models/user_model.dart';
import 'package:alonu_app/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserModel.fromJson tolerates non-string payloads', () {
    final user = UserModel.fromJson({
      'id': ['123'],
      'username': ['demo'],
      'email': ['demo@example.com'],
      'nom': ['Doe'],
      'prenom': ['Jane'],
      'telephone': ['123456'],
      'role': ['CLIENT'],
      'status': ['ACTIVE'],
      'avatar': ['avatar.jpg'],
      'countryId': ['fr'],
      'createdAt': '2024-01-01T00:00:00.000Z',
    });

    expect(user.id, '123');
    expect(user.username, 'demo');
    expect(user.email, 'demo@example.com');
    expect(user.nom, 'Doe');
    expect(user.prenom, 'Jane');
    expect(user.telephone, '123456');
    expect(user.role, UserRole.CLIENT);
    expect(user.status, UserStatus.ACTIVE);
    // L'avatar est résolu en URL absolue (voir AppConstants.resolveMediaUrl),
    // l'API renvoyant des chemins relatifs pour les fichiers uploadés.
    expect(user.avatar, AppConstants.resolveMediaUrl('avatar.jpg'));
    expect(user.countryId, 'fr');
  });

  test(
    'AuthResponseModel.fromJson tolerates malformed nested user payloads',
    () {
      final authResponse = AuthResponseModel.fromJson({
        'accessToken': ['token-value'],
        'refreshToken': ['refresh-value'],
        'expiresAt': '2024-01-01T00:00:00.000Z',
        'user': ['unexpected-list'],
      });

      expect(authResponse.accessToken, 'token-value');
      expect(authResponse.refreshToken, 'refresh-value');
      expect(authResponse.user.username, '');
    },
  );
}
