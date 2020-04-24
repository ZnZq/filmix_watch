import 'package:filmix_watch/managers/media_manager.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/media/translate.dart';
import 'package:filmix_watch/widgets/media_explorer.dart';
import 'package:flutter/material.dart';

class MediaView extends StatefulWidget {
  final MediaPost post;

  MediaView(this.post);

  @override
  _MediaViewState createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView>
    with AutomaticKeepAliveClientMixin<MediaView> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var bloc = MediaManager(widget.post);
    return StreamBuilder<List<Translate>>(
      stream: bloc.controller,
      initialData: bloc.controller.value,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        if (snapshot.data.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Данных нет'),
                OutlineButton(
                  child: Text('Загрузить'),
                  onPressed: () {
                    bloc.loadMedia(250);
                  },
                )
              ],
            ),
          );
        }

        return MediaExplorer(widget.post, snapshot.data);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
