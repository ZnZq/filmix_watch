import 'package:filmix_watch/pages/data_page.dart';
import 'package:filmix_watch/pages/favorite_page.dart';
import 'package:filmix_watch/pages/main_page.dart';
import 'package:filmix_watch/pages/search_page.dart';
import 'package:filmix_watch/pages/settings_page.dart';
import 'package:filmix_watch/tiles/auth_tile.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({Key key, this.currentRoute = '/'}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 4),
            AuthTile(),
            SizedBox(height: 4),
            Divider(height: 0),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildDrawerItemReplacePush(
                    icon: Icons.home,
                    text: MainPage.title,
                    route: MainPage.route,
                  ),
                  Divider(height: 0),
                  _buildDrawerItemPush(
                    icon: Icons.search,
                    text: SearchPage.title,
                    route: SearchPage.route,
                  ),
                  Divider(height: 0),
                  _buildDrawerItemPush(
                    icon: Icons.star_border,
                    text: FavoritePage.title,
                    route: FavoritePage.route,
                  ),
                  Divider(height: 0),
                  _buildDrawerItemPush(
                      icon: Icons.filter_drama,
                      text: DataPage.title,
                      route: DataPage.route),
                  Divider(height: 0),
                ],
              ),
            ),
            Divider(height: 0),
            _buildDrawerItemPush(
              icon: Icons.settings,
              text: SettingsPage.title,
              route: SettingsPage.route,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItemReplacePush(
      {IconData icon, String text, String route, argumets}) {
    return _buildDrawerItem(
      icon: icon,
      text: text,
      selected: route == widget.currentRoute,
      onTap: () {
        if (route != widget.currentRoute) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route, arguments: argumets);
        }
      },
    );
  }

  Widget _buildDrawerItemPush(
      {IconData icon, String text, String route, argumets}) {
    return _buildDrawerItem(
      icon: icon,
      text: text,
      selected: route == widget.currentRoute,
      onTap: () {
        if (route != widget.currentRoute) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route, arguments: argumets);
        }
      },
    );
  }

  Widget _buildDrawerItem({
    IconData icon,
    String text,
    GestureTapCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      selected: selected,
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
