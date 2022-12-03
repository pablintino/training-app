import 'package:flutter/material.dart';

class CommonSliverAppBar extends StatelessWidget {
  final Widget title;
  final Image? background;
  final List<Widget>? options;
  final double titleWidthProportion;
  final bool automaticallyImplyLeading;
  final double expandedHeight;
  final bool floating;
  final bool pinned;
  final EdgeInsetsGeometry? titlePadding;

  const CommonSliverAppBar(
      {Key? key,
      required this.title,
      this.options,
      this.background,
      this.automaticallyImplyLeading = true,
      this.titlePadding,
      this.titleWidthProportion = 0.75,
      this.expandedHeight = 125,
      this.floating = true,
      this.pinned = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      flexibleSpace: Stack(
        children: <Widget>[
          Positioned.fill(
            child: background ?? Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * titleWidthProportion,
                child: FlexibleSpaceBar(
                  title: title,
                  titlePadding: titlePadding ??
                      (EdgeInsetsDirectional.only(
                          start: automaticallyImplyLeading ? 50 : 16,
                          bottom: 16)),
                ),
              ),
              Expanded(child: Container()),
              if (options != null) ...options!
            ],
          )
        ],
      ),
    );
  }
}
