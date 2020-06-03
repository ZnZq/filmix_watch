import 'package:filmix_watch/managers/mirror_manager.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

class MirrorTile extends StatefulWidget {
  final String mirror;

  MirrorTile(this.mirror);

  @override
  _MirrorTileState createState() => _MirrorTileState();
}

class _MirrorTileState extends State<MirrorTile> {
  bool state;
  bool loading = true;
  int status;
  DateTime startTime;
  DateTime endTime;

  @override
  void initState() {
    super.initState();
    check();
  }

  check() {
    setState(() {
      state = null;
      status = null;
      endTime = null;
      loading = true;
    });
    startTime = DateTime.now();
    http.get('https://${widget.mirror}').then((response) {
      endTime = DateTime.now();
      setState(() {
        state = response.statusCode == 200;
        status = response.statusCode;
        loading = false;
      });
    });
  }

  // static DateFormat format = DateFormat('');

  @override
  Widget build(BuildContext context) {
    var selected = widget.mirror == MirrorManager.currentMirror;
    return ListTile(
      selected: selected,
      leading: state == null
          ? CircularProgressIndicator()
          : CircleAvatar(
              child: state ? Icon(Icons.check) : Icon(Icons.close),
            ),
      title: Text(widget.mirror),
      isThreeLine: true,
      subtitle: status == null
          ? Text('Загрузка...')
          : Text(
              'Статус: $status\nПинг: ${endTime.difference(startTime).inMilliseconds}ms',
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            CircularProgressIndicator()
          else
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                check();
              },
            ),
          if (!selected && state == true)
            IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: () {
                MirrorManager.selectMirror(widget.mirror);
              },
            ),
          if (!selected && state != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                var remove = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Удаление'),
                    content: Text(
                        'Вы действительно хотите удалить зеркало "${widget.mirror}"?'),
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
                if (remove) MirrorManager.removeMirror(widget.mirror);
              },
            ),
        ],
      ),
    );
  }
}
