// import 'package:filmix_watch/filmix/media/translation.dart';
// import 'package:filmix_watch/tiles/episode_tile.dart';
// import 'package:flutter/material.dart';

// class SeasonTile extends StatefulWidget {
//   final SerialTranslation serialTranslation;

//   SeasonTile(this.serialTranslation);

//   @override
//   _SeasonTileState createState() => _SeasonTileState();
// }

// class _SeasonTileState extends State<SeasonTile> with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       itemBuilder: (BuildContext context, int index) {
//         var season = widget.serialTranslation.seasons[index];
//         return ExpansionTile(
//           title: Text(season.title),
//           children: [
//             for (var episode in season.episodes)
//               ...[
//                 Divider(height: 0),
//                 EpisodeTile(episode)
//               ]
//           ],
//         );
//       },
//       itemCount: widget.serialTranslation.seasons.length,
//       separatorBuilder: (BuildContext context, int index) => Divider(height: 0),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
