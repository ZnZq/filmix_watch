import 'package:filmix_watch/managers/history_manager.dart';
import 'package:filmix_watch/managers/post_manager.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/tiles/history_post_tile.dart';
import 'package:filmix_watch/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  static final String route = '/history';
  static final String title = 'История';

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(HistoryPage.title),
      ),
      drawer: AppDrawer(currentRoute: HistoryPage.route),
      body: StreamBuilder(
        stream: HistoryManager.updateController,
        builder: (context, snapshot) {
          var historyList = HistoryManager.getHistory();

          if (historyList.isEmpty) {
            return Center(child: Text('Данных нет'));
          }

          var steps = <Step>[];

          for (var history in historyList.entries) {
            var posts = history.value;

            var historyPosts = <Widget>[];

            for (var hist in posts.entries) {
              var postId = hist.key;
              for (var items in hist.value) {
                // print('$postId: ${items.map((e) => e.title).join(' - ')}');

                var post = PostManager.posts[postId];

                historyPosts.add(
                  GestureDetector(
                    child: HistoryPostTile(
                      post: post,
                      historyItems: items,
                      hero: items.last.id.toString(),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, PostPage.route, arguments: {
                        'hero': post.originName,
                        'post': post,
                      });
                    },
                  ),
                );
                historyPosts.add(SizedBox(height: 4));
              }
            }

            steps.add(Step(
                isActive: true,
                title: Text(history.key),
                state: StepState.complete,
                content: Column(
                  children: historyPosts,
                )
                // content: ListView.separated(
                //   shrinkWrap: true,
                //   itemBuilder: (context, index) {
                //     return historyPosts[index];
                //   },
                //   separatorBuilder: (_, __) => SizedBox(height: 4),
                //   itemCount: historyPosts.length,
                // ),
                ));
          }

          return Stepper(
            currentStep: currentStep,
            controlsBuilder: (_, {onStepContinue, onStepCancel}) => Container(),
            steps: steps,
            onStepTapped: (step) {
              print(step);
              setState(() {
                currentStep = step;
              });
            },
          );
        },
      ),
    );
  }
}
