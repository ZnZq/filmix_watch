import 'package:filmix_watch/bloc/search_manager.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/tiles/search_post_tile.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  static final String route = '/search';
  static final String title = 'Поиск';

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SearchManager.data.clear();
    SearchManager.searchController.add(SearchState.loaded());
    // focusNode.nextFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          focusNode: focusNode,
          controller: searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Поиск',
          ),
          onEditingComplete: () {
            SearchManager.search(searchController.text);
            focusNode.unfocus();
          },
        ),
      ),
      // drawer: AppDrawer(
      //   currentRoute: SearchPage.route,
      // ),
      body: StreamBuilder<SearchState>(
        stream: SearchManager.searchController,
        initialData: SearchManager.searchController.value,
        builder: (context, snapshot) {
          if (snapshot.data.isLoaded) {
            if (SearchManager.data.isEmpty) {
              return Center(child: Text('Данных нет'));
            }
            return ListView.separated(
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                var post = SearchManager.data[index];
                return GestureDetector(
                  child: SearchPostTile(post),
                  onTap: () {
                    Navigator.pushNamed(context, PostPage.route, arguments: {
                      'hero': 'search',
                      'post': post,
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemCount: SearchManager.data.length,
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
