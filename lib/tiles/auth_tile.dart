import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmix_watch/bloc/auth_manager.dart';
import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/pages/auth_page.dart';
import 'package:flutter/material.dart';

class AuthTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthManager.authController,
      initialData: AuthManager.authController.value,
      builder: (context, snapshot) {
        switch (snapshot.data) {
          case AuthState.auth:
            return ListTile(
              title: Text(Filmix.user.name, style: TextStyle(fontSize: 18),),
              leading: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: NetworkImage(Filmix.user.avatar))
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  AuthManager.logout();
                },
              ),
            );
          case AuthState.login:
            return ListTile(
              title: Text('Войти'),
              leading: Icon(Icons.people),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AuthPage.route);
              },
            );
          case AuthState.loading:
            return ListTile(
              title: LinearProgressIndicator(),
            );
        }
      },
    );
  }
}
