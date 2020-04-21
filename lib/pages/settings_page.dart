import 'package:filmix_watch/settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  static final String route = '/settings';
  static final String title = 'Настройки';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsPage.title),
      ),
      body: StreamBuilder(
        stream: Settings.updateController,
        builder: (_, __) {
          return ListView(
            shrinkWrap: true,
            children: [
              ListTile(title: Center(child: Text('Настройки главной страницы'))),
              Divider(height: 0),
              _switch(
                'Умный скролл',
                Settings.smartScroll,
                (value) => Settings.smartScroll = value,
              ),
              Divider(height: 0),
              ListTile(title: Center(child: Text('Настройки постера'))),
              Divider(height: 0),
              _switch(
                'Отображать качество',
                Settings.showPostQuality,
                (value) => Settings.showPostQuality = value,
              ),
              Divider(height: 0),
              _switch(
                'Отображать последнюю серию',
                Settings.showPostAdded,
                (value) => Settings.showPostAdded = value,
              ),
              Divider(height: 0),
              _switch(
                'Отображать время добавления',
                Settings.showPostTime,
                (value) => Settings.showPostTime = value,
              ),
              Divider(height: 0),
              _switch(
                'Отображать тип материала',
                Settings.showPostType,
                (value) => Settings.showPostType = value,
              ),
              Divider(height: 0),
              _switch(
                'Отображать позицию',
                Settings.showPostNumber,
                (value) => Settings.showPostNumber = value,
              ),
              Divider(height: 0),
              _switch(
                'Отображать рейтинг',
                Settings.showPostLike,
                (value) => Settings.showPostLike = value,
              ),
              Divider(height: 0),
            ],
          );
        },
      ),
    );
  }

  Widget _switch(String title, bool value, Function(bool) update) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) {
        update(newValue);
        Settings.save();
      },
    );
  }
}
