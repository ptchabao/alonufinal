import 'package:alonu_app/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RegisterRequestModel includes workshop location in payload', () {
    final model = RegisterRequestModel(
      username: 'artisan01',
      email: 'artisan@example.com',
      password: 'password123',
      nom: 'Kouame',
      prenom: 'Awa',
      telephone: '690000000',
      role: 'ARTISAN',
      countryId: 'CM',
      referralCode: 'PROMO123',
      workshopLocation: 'Centre commercial de la ville',
    );

    expect(model.toJson()['workshopLocation'], 'Centre commercial de la ville');
    expect(model.toJson()['referralCode'], 'PROMO123');
  });

  test('RegisterRequestModel preserves nullable workshop location', () {
    final model = RegisterRequestModel(
      username: 'client01',
      email: 'client@example.com',
      password: 'password123',
      nom: 'Doe',
      prenom: 'John',
      telephone: '670000000',
      role: 'CLIENT',
      countryId: 'CM',
      workshopLocation: null,
    );

    expect(model.toJson()['workshopLocation'], isNull);
  });
}
