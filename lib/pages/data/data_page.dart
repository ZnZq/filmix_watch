import 'package:filmix_watch/bloc/filter_manager.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:flutter/material.dart';

class DataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Данные'),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            title: Text('Фильтры'),
            children: [
              Divider(height: 0),
              _filterTile('Список переводов', FilterType.translation),
              _filterTile('Список качеств', FilterType.rip),
              _filterTile('Список жанров', FilterType.categories),
              _filterTile('Список стран', FilterType.countries),
              _filterTile('Список годов', FilterType.years),
            ],
          )
        ],
      ),
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
                contentPadding: FilterManager.data[type].isEmpty ? EdgeInsets.all(20) : EdgeInsets.only(top: 20),
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
