import 'package:filmix_watch/filmix/filmix.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class AuthManager {
  static BehaviorSubject<AuthState> authController;

  static init() async {
    authController = BehaviorSubject<AuthState>.seeded(AuthState.loading);

    var box = Hive.box('filmix');
    var userId = box.get('user_id', defaultValue: '').toString();
    var password = box.get('password', defaultValue: '').toString();

    if (userId.isEmpty || password.isEmpty) {
      authController.add(AuthState.login);
      return;
    }

    Filmix.getUser(userId, password).then((value) {
      authController.add(value ? AuthState.auth : AuthState.login);
    });
  }

  static Future<String> login(String login, String password) async {
    authController.add(AuthState.loading);
    var result = await Filmix.auth(login, password);
    authController.add(result == 'AUTHORIZED' ? AuthState.auth : AuthState.login);
    return result;
  }

  static logout() {
    Filmix.logout();
    authController.add(AuthState.login);
  }
}

enum AuthState { auth, login, loading }
