import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/select_practice/models/user.dart';

final userProvider =
    NotifierProvider<UserNotifier, User>(
  UserNotifier.new,
);

class UserNotifier extends Notifier<User> {
  @override
  User build() {
    return User(
      name: 'Hamad',
      age: 26,
      email: 'hamad@example.com',
    );
  }

  void updateName(String name) {
    state = state.copyWith(
      name: name,
    );
  }

  void updateAge(int age) {
    state = state.copyWith(
      age: age,
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
    );
  }
}