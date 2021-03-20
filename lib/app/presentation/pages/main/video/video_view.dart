import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:search_gold_quotes/app/domain/entities/video_items.dart';
import 'package:search_gold_quotes/app/presentation/pages/main/video/video/video_bloc.dart';
import 'package:search_gold_quotes/app/presentation/style/TextStyles.dart';
import 'package:search_gold_quotes/app/presentation/widgets/message_display.dart';
import 'package:search_gold_quotes/app/presentation/widgets/navigation_main_scrollable_widget.dart';
import 'package:search_gold_quotes/core/di/injection_container.dart';
import 'package:search_gold_quotes/core/platform/device_utils.dart';
import 'package:search_gold_quotes/core/presentation/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:search_gold_quotes/core/theme/theme_notifier.dart';
import 'package:search_gold_quotes/core/values/dimens.dart';
import 'package:search_gold_quotes/core/values/strings.dart';
import 'package:shimmer/shimmer.dart';

class VideoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => container<VideoBloc>(),
      child: CustomScrollView(slivers: [
        NavigationMainScrollableWidget(title: Strings.titleVideo),
        SliverToBoxAdapter(
          child: VideoContainer(),
        )
      ]),
    );
  }
}

class VideoContainer extends StatefulWidget {
  @override
  _VideoContainer createState() => _VideoContainer();
}

class _VideoContainer extends State<VideoContainer> {
  @override
  void initState() {
    super.initState();
    _dispatchVideoData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(builder: (bloc, state) {
      if (state is Loading) {
        return LoadingListWidget();
      } else if (state is Loaded) {
        return VideoListWidget(videoList: state.videoList);
      } else if (state is Error) {
        return MessageDisplay(message: state.message);
      }
      return Container();
    });
  }

  void _dispatchVideoData() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<VideoBloc>(context, listen: false)
          .add(GetVideoListOnLoaded());
    });
  }
}

class LoadingListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: Colors.red,
        highlightColor: Colors.yellow,
        child: Text(
          'Shimmer',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    ;
  }
}

class VideoListWidget extends StatefulWidget {
  final VideoList videoList;

  VideoListWidget({@required this.videoList});

  @override
  _VideoListWidget createState() => _VideoListWidget();
}

class _VideoListWidget extends State<VideoListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
  }

  void _pushToVideoPlayerPage(BuildContext context, int index) {
    context.router.push(VideoPlayerPage(
        youtubeIDList:
            widget.videoList.itemList.map((item) => item.linkURL).toList(),
        startIndex: index));
  }
}

class VideoItemWidget extends StatelessWidget {
  final VideoItem videoItem;
  final String placeHolderAsset = 'images/placeholder_white.png';

  VideoItemWidget({@required this.videoItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        videoItem.imagePath != null
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
                placeholder: (context, url) => Image.asset(placeHolderAsset),
                errorWidget: (context, url, error) =>
                    Image.asset(placeHolderAsset),
              )
            : Container(
                height: 200,
                width: DeviceUtils.screenWidth(context),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                  image: AssetImage(placeHolderAsset),
                )),
              ),
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
