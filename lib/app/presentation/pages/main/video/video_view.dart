import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_gold_quotes/app/domain/entities/video_items.dart';
import 'package:search_gold_quotes/app/presentation/pages/main/video/video/video_bloc.dart';
import 'package:search_gold_quotes/app/presentation/style/TextStyles.dart';
import 'package:search_gold_quotes/app/presentation/widgets/message_display.dart';

import 'package:search_gold_quotes/app/presentation/widgets/navigation_main_widget.dart';
import 'package:search_gold_quotes/core/di/injection_container.dart';
import 'package:search_gold_quotes/core/platform/device_utils.dart';
import 'package:search_gold_quotes/core/presentation/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:search_gold_quotes/core/theme/theme_notifier.dart';
import 'package:search_gold_quotes/core/values/dimens.dart';
import 'package:search_gold_quotes/core/values/strings.dart';
import 'package:shimmer/shimmer.dart';

class VideoView extends StatelessWidget {
  const VideoView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => container<VideoBloc>(), child: _VideoContainer());
  }
}

// class _VideoPullRefreshWidget extends StatefulWidget {
//   _VideoPullRefreshWidget({Key key}) : super(key: key);

//   @override
//   _VideoPullRefreshWidgetState createState() => _VideoPullRefreshWidgetState();
// }

// class _VideoPullRefreshWidgetState extends State<_VideoPullRefreshWidget> {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: NavigationMainWidget(title: Strings.titleVideo),
//       body: SmartRefresher(
//           enablePullDown: true,
//           enablePullUp: false,
//           header: ClassicHeader(),
//           controller: _refreshController,
//           onRefresh: _dispatchVideoData,
//           child: _VideoContainer()),
//     );
//   }

//   void _dispatchVideoData() async {
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       BlocProvider.of<VideoBloc>(context, listen: false)
//           .add(GetVideoListOnLoaded());
//     });
//   }
// }

class _VideoContainer extends StatefulWidget {
  _VideoContainer({Key key}) : super(key: key);

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

class _VideoContainerState extends State<_VideoContainer> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _refreshController.refreshCompleted();
    _dispatchVideoData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NavigationMainWidget(title: Strings.titleVideo),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: ClassicHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: BlocBuilder<VideoBloc, VideoState>(builder: (bloc, state) {
            if (state is Loading) {
              return _LoadingListWidget();
            } else if (state is Loaded) {
              _refreshController.refreshCompleted();
              return _VideoListWidget(videoList: state.videoList);
            } else if (state is Error) {
              _refreshController.refreshFailed();
              return MessageDisplay(message: state.message);
            }
          }),
        ));
  }

  void _dispatchVideoData() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<VideoBloc>(context, listen: false)
          .add(GetVideoListOnLoaded());
    });
  }

  void _onRefresh() {
    context.read<VideoBloc>().add(GetVideoListOnLoaded());
  }
}

class _LoadingListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      enabled: true,
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimens.margin),
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (context, index) {
          return _LoadingListItemWidget();
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }
}

class _LoadingListItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 200, width: double.infinity, color: Colors.white),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        Container(
            width: DeviceUtils.screenWidth(context),
            height: 44,
            color: Colors.white),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 3.0),
        ),
        Container(
            width: DeviceUtils.screenWidth(context) / 2,
            height: 22,
            color: Colors.white),
      ],
    );
  }
}

class _VideoListWidget extends StatefulWidget {
  final VideoList videoList;

  _VideoListWidget({Key key, @required this.videoList});

  @override
  _VideoListWidgetState createState() => _VideoListWidgetState();
}

class _VideoListWidgetState extends State<_VideoListWidget> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(Dimens.margin),
      shrinkWrap: true,
      itemCount: widget.videoList.itemList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: VideoItemWidget(videoItem: widget.videoList.itemList[index]),
          onTap: () => _pushToVideoPlayerPage(context, index),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
    // RefreshIndicator(
    //     child: ListView.separated(
    //       padding: const EdgeInsets.all(Dimens.margin),
    //       shrinkWrap: true,
    //       itemCount: widget.videoList.itemList.length,
    //       itemBuilder: (context, index) {
    //         return GestureDetector(
    //           child:
    //               VideoItemWidget(videoItem: widget.videoList.itemList[index]),
    //           onTap: () => _pushToVideoPlayerPage(context, index),
    //         );
    //       },
    //       separatorBuilder: (context, index) {
    //         return Divider();
    //       },
    //       // ),
    //     ),
    //     onRefresh: () => _reloadVideoData());
  }

  void _pushToVideoPlayerPage(BuildContext context, int index) {
    context.router.push(VideoPlayerPage(
        youtubeIDList:
            widget.videoList.itemList.map((item) => item.linkURL).toList(),
        startIndex: index));
  }

  void _dispatchVideoData(BuildContext context) async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<VideoBloc>(context, listen: false)
          .add(GetVideoListOnLoaded());
    });
  }
}

class VideoItemWidget extends StatelessWidget {
  final VideoItem videoItem;
  final String placeHolderDarkAsset = 'images/placeholder_white.png';
  final String placeHolderLightAsset = 'images/placeholder_black.png';

  VideoItemWidget({@required this.videoItem});

  @override
  Widget build(BuildContext context) {
    var themeService = Provider.of<ThemeNotifier>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
            tag: videoItem.linkURL,
            child: videoItem.imagePath != null
                ? CachedNetworkImage(
                    fit: BoxFit.fitWidth,
                    imageUrl: videoItem.imagePath,
                    imageBuilder: (context, imageProvider) => Container(
                      height: 200,
                      width: DeviceUtils.screenWidth(context),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fitWidth,
                      )),
                    ),
                    placeholder: (context, url) => Image.asset(
                        themeService.getThemeIsDark()
                            ? placeHolderDarkAsset
                            : placeHolderLightAsset),
                    errorWidget: (context, url, error) => Image.asset(
                        themeService.getThemeIsDark()
                            ? placeHolderDarkAsset
                            : placeHolderLightAsset),
                  )
                : Container(
                    height: 200,
                    width: DeviceUtils.screenWidth(context),
                    decoration: new BoxDecoration(
                        image: new DecorationImage(
                      image: AssetImage(themeService.getThemeIsDark()
                          ? placeHolderDarkAsset
                          : placeHolderLightAsset),
                    )),
                  )),
        Text(videoItem.title,
            textAlign: TextAlign.start,
            maxLines: 2,
            style: TextPrimaryContrastingStyles.titleStyle(context)),
        Text(videoItem.subTitle,
            textAlign: TextAlign.start,
            maxLines: 2,
            style: TextPrimaryContrastingStyles.defaultStyle(context)),
      ],
    );
  }
}
