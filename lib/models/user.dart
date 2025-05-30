enum UserRole { cashier, admin }
//cashier - Роль обычного пользователя
//admin   - Роль администратора
class User {
  final String username;
  final String password;
  final String inn;
  final UserRole role;

  User({
    required this.username,
    required this.password,
    required this.inn,
    this.role = UserRole.cashier, // По умолчанию будет подставляться пользователь кассир "cashier"
  });
}
