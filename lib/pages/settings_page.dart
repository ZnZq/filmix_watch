import 'dart:io';

// import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:filmix_watch/managers/mirror_manager.dart';
import 'package:filmix_watch/settings.dart';
import 'package:filmix_watch/tiles/mirror_tile.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
              _buildMainSetting(context),
              _buildMainPageSetting(),
              _buildPosterSetting(),
              _buildMirrorSetting(),
              ExpansionTile(
                title: Text('Загрузки'),
                children: [
                  ListTile(
                    title: Text('Папка для загрузки'),
                    subtitle: Text(Settings.downloadFolder),
                    trailing: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        Settings.downloadFolder = '/storage/emulated/0/';
                        Settings.save();
                      },
                    ),
                    onTap: () async {
                      var path = await FilePicker.getDirectoryPath();
                      // String path = await FilesystemPicker.open(
                      //   title: 'Папка для загрузки',
                      //   context: context,
                      //   rootDirectory: Directory('/storage/emulated/0/'),
                      //   rootName: 'Хранилище',
                      //   fsType: FilesystemType.folder,
                      //   pickText: 'Выбрать',
                      // );
                      if (path == null || path.isEmpty) {
                        return;
                      }

                      Settings.downloadFolder = path;
                      Settings.save();
                    },
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  StreamBuilder _buildMirrorSetting() {
    return StreamBuilder(
      stream: MirrorManager.updateController,
      builder: (context, snapshot) {
        return ExpansionTile(
          title: Text('Зеркала'),
          subtitle: Text('Текущее зеркало: ${MirrorManager.currentMirror}'),
          children: [
            for (var mirror in MirrorManager.mirrors) MirrorTile(mirror)
          ],
        );
      },
    );
  }

  ExpansionTile _buildPosterSetting() {
    return ExpansionTile(
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
    );
  }

  ExpansionTile _buildMainPageSetting() {
    return ExpansionTile(
      title: Text('Настройки главной страницы'),
      children: [
        _switch(
          'Умный скролл',
          Settings.smartScroll,
          (value) => Settings.smartScroll = value,
        ),
      ],
    );
  }

  ExpansionTile _buildMainSetting(BuildContext context) {
    return ExpansionTile(
      title: Text('Основное'),
      children: [
        _switch('Обход Full HD', Settings.freeFullHD,
            (value) => Settings.freeFullHD = value,
            subtitle:
                'Если выключено, вам необходмо быть авторизованным, что бы смотреть в HD качестве и Full HD+ качество будет не доступно!\n\nВозможны Wrong Link. Попробуйте перезагрузить данные, если не поможет, выключите этот режим!'),
        if (Settings.freeFullHD)
          Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200, minHeight: 0),
                child: ListView(
                  shrinkWrap: true,
                  children: Settings.fullHDCodes
                      .map((e) => ListTile(
                            title: Center(
                              child: Text(e, style: TextStyle(fontSize: 12)),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () => removeCode(context, e),
                            ),
                          ))
                      .toList(),
                ),
              ),
              FlatButton(
                child: Text('Добавить код'),
                onPressed: () async {
                  var code = await showDialog<String>(
                    context: context,
                    builder: (context) => AddCodeDialog(),
                  );

                  if (code != null) {
                    Settings.fullHDCodes.add(code);
                    Settings.save();
                  }
                },
              )
            ],
          )
      ],
    );
  }

  removeCode(context, e) async {
    var remove = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Удаление'),
        content: Text('Вы действительно хотите удалить код "$e"?'),
        actions: [
          FlatButton(
            child: Text('Отмена'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text('Удалить'),
            textColor: Colors.red,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (remove) {
      Settings.fullHDCodes.remove(e);
      Settings.save();
    }
  }

  Widget _switch(String title, bool value, Function(bool) update,
      {String subtitle}) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: (newValue) {
        update(newValue);
        Settings.save();
      },
    );
  }
}

class AddCodeDialog extends StatefulWidget {
  @override
  _AddCodeDialogState createState() => _AddCodeDialogState();
}

class _AddCodeDialogState extends State<AddCodeDialog> {
  var input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Добавление кода'),
      content: TextField(
        controller: input,
        decoration: InputDecoration(labelText: 'Код'),
        maxLength: 38,
        onChanged: (text) {
          setState(() {});
        },
      ),
      actions: [
        FlatButton(
          child: Text('Отмена'),
          onPressed: () => Navigator.pop(context, null),
        ),
        FlatButton(
          child: Text('Добавить'),
          onPressed: input.text.trim().isNotEmpty && input.text.length == 38
              ? () {
                  Navigator.pop(context, input.text);
                }
              : null,
        ),
      ],
    );
  }
}
