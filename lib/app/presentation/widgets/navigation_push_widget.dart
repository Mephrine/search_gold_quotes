import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:search_gold_quotes/core/presentation/routes/router.gr.dart';
import 'package:search_gold_quotes/core/values/colors.dart';
import 'package:search_gold_quotes/core/values/dimens.dart';

class NavigationPushWidget extends StatelessWidget with PreferredSizeWidget {
  final String title;

  const NavigationPushWidget({@required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).accentColor,
      leading: MaterialButton(
          padding: EdgeInsets.fromLTRB(Dimens.margin, 0, 0, 0),
          child: Icon(Icons.arrow_back_outlined,
              color: Palette.iconColor, size: Dimens.iconSizeTitle),
          onPressed: () => context.rootNavigator.pop()),
      title: Text(
        title,
        style: TextStyle(
            fontSize: Dimens.fontTextTitle, color: Palette.naviTitleColor),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
