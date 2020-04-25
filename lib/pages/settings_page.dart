import 'package:filmix_watch/managers/mirror_manager.dart';
import 'package:filmix_watch/settings.dart';
import 'package:filmix_watch/tiles/mirror_tile.dart';
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
              ExpansionTile(
                title: Text('Настройки главной страницы'),
                children: [
                  _switch(
                    'Умный скролл',
                    Settings.smartScroll,
                    (value) => Settings.smartScroll = value,
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('Настройки постера'),
                children: [
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
                ],
              ),
              StreamBuilder(
                stream: MirrorManager.updateController,
                builder: (context, snapshot) {
                  return ExpansionTile(
                    title: Text('Зеркала'),
                    subtitle: Text('Текущее зеркало: ${MirrorManager.currentMirror}'),
                    children: [
                      for (var mirror in MirrorManager.mirrors) 
                        MirrorTile(mirror)
                    ],
                  );
                },
              ),
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
