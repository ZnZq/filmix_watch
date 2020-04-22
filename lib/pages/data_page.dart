import 'package:filmix_watch/bloc/filter_manager.dart';
import 'package:filmix_watch/bloc/media_manager.dart';
import 'package:filmix_watch/bloc/post_manager.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class DataPage extends StatefulWidget {
  static final String route = '/data';
  static final String title = 'Данные';

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DataPage.title),
      ),
      drawer: AppDrawer(currentRoute: DataPage.route),
      body: ListView(
        children: [
          _buildFilterTile(),
          _buildMediaTile(context),
        ],
      ),
    );
  }

  Widget _buildMediaTile(BuildContext context) {
    return ExpansionTile(
      title: Text('Медиа данные'),
      children: MediaManager.mediaIds.map((e) {
        var post = PostManager.posts[e];
        return ListTile(
          title: Text(
            '[${post.type == PostType.serial ? 'Сериал' : 'Фильм'}] ${post.name}',
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              var remove = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Удаление'),
                  content: Text(
                      'Вы действительно хотите удалить медиа данные ${post.type == PostType.serial ? 'сериала' : 'фильма'} "${post.name}"?'),
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
                MediaManager.remove(post.id);
                setState(() {});
              }
            },
          ),
          onTap: () {
            Navigator.pushNamed(context, PostPage.route, arguments: {
              'hero': 'data',
              'post': post,
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFilterTile() {
    return ExpansionTile(
      title: Text('Фильтры'),
      children: [
        Divider(height: 0),
        _filterTile('Список переводов', FilterType.translation),
        _filterTile('Список качеств', FilterType.rip),
        _filterTile('Список жанров', FilterType.categories),
        _filterTile('Список стран', FilterType.countries),
        _filterTile('Список годов', FilterType.years),
      ],
    );
  }

  Widget _filterTile(String title, FilterType type) {
    return StreamBuilder<FilterState>(
      stream: FilterManager.streams[type],
      initialData: FilterManager.streams[type].value,
      builder: (BuildContext context, AsyncSnapshot<FilterState> snapshot) {
        return ListTile(
          contentPadding: EdgeInsets.only(left: 16, right: 16),
          leading: CircleAvatar(
            child: Text(FilterManager.data[type].length.toString()),
          ),
          title: Text(title),
          trailing: IconButton(
            icon: snapshot.data.isLoaded
                ? Icon(Icons.refresh, color: Colors.blue)
                : CircularProgressIndicator(),
            onPressed: snapshot.data.isLoaded
                ? () => FilterManager.updateData(type)
                : null,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                contentPadding: FilterManager.data[type].isEmpty
                    ? EdgeInsets.all(20)
                    : EdgeInsets.only(top: 20),
                title: Center(child: Text(title)),
                content: FilterManager.data[type].isEmpty
                    ? Text('Данных нет')
                    : Container(
                        width: double.maxFinite,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(
                              FilterManager.data[type].values.toList()[index],
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 16, right: 16),
                          ),
                          itemCount: FilterManager.data[type].length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 0),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
