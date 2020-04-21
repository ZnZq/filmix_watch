import 'package:filmix_watch/bloc/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthPage extends StatefulWidget {
  static final String route = '/auth';

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация Filmix'),
      ),
      body: StreamBuilder<AuthState>(
        stream: AuthManager.authController,
        initialData: AuthManager.authController.value,
        builder: (context, snapshot) {
          return Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(24),
                      margin: EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(0xFF, 0x29, 0x2c, 0x33),
                        boxShadow: [
                          BoxShadow(color: Colors.white24, spreadRadius: .5)
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogo(),
                          TextField(
                            controller: loginController,
                            decoration: InputDecoration(labelText: 'Логин'),
                          ),
                          TextField(
                            controller: passController,
                            decoration: InputDecoration(labelText: 'Пароль'),
                            obscureText: true,
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlineButton(
                              child: Text('Войти'),
                              onPressed: () async {
                                var result = await AuthManager.login(
                                    loginController.text, passController.text);
                                if (result == 'AUTHORIZED') {
                                  Navigator.pop(context);
                                } else
                                  Fluttertoast.showToast(msg: result);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (snapshot.data == AuthState.loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                  ),
                ),
              if (snapshot.data == AuthState.loading)
                Center(child: CircularProgressIndicator())
            ],
          );
        },
      ),
    );
  }

  Material _buildLogo() {
    return Material(
      textStyle: TextStyle(
        fontSize: 46,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filmix'),
          Text(
            ' \u2023 ',
            style: TextStyle(color: Colors.orange),
          ),
          Text('HD'),
        ],
      ),
    );
  }
}
