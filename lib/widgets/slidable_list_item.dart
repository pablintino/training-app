import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:training_app/widgets/simple_list_item.dart';

class SlidableListItem extends StatelessWidget {
  final int itemId;
  final String? itemTitle;
  final String? itemSubtitle;
  final Function(int)? onDelete;
  final Function(int)? onEdit;

  const SlidableListItem(this.itemId,
      {this.itemTitle, this.itemSubtitle, this.onDelete, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(itemId),
      groupTag: 'items',
      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 1,
            onPressed: onDelete != null ? (_) => onDelete!(itemId) : null,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: onEdit != null ? (_) => onEdit!(itemId) : null,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      child: SimpleListItem(itemId,
          itemTitle: itemTitle, itemSubtitle: itemSubtitle),
    );
  }
}
