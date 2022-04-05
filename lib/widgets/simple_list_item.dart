import 'package:flutter/material.dart';
import 'package:training_app/widgets/two_letters_icon.dart';

class SimpleListItem extends StatelessWidget {
  final int itemId;
  final String? itemTitle;
  final String? itemSubtitle;
  final Function(int)? onClick;

  const SimpleListItem(this.itemId,
      {this.itemTitle, this.itemSubtitle, this.onClick});

  @override
  Widget build(BuildContext context) {
    final subTitle = itemSubtitle ?? '';
    return ListTile(
      title: Text(itemTitle ?? 'No name'),
      subtitle: Text(subTitle.length >= 40
          ? subTitle.replaceRange(40, subTitle.length, '...')
          : subTitle),
      leading: Container(
        margin: EdgeInsets.only(top: 8),
        child: TwoLettersIcon(itemTitle ?? ''),
      ),
      onTap: onClick != null ? () => onClick!(itemId) : null,
    );
  }
}
