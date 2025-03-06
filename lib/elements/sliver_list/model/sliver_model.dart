import 'package:flutter/cupertino.dart';

typedef RemovedItemBuilder<E> = Widget Function(
  E item,
  BuildContext context,
  Animation<double> animation,
);

class SliverModel<E> {
  SliverModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<SliverAnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  SliverAnimatedListState get _animatedList => listKey.currentState!;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
        index,
        (BuildContext context, Animation<double> animation) =>
            removedItemBuilder(removedItem, context, animation),
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  bool get isEmpty => _items.isEmpty;

  void removeAll() {
    for (var i = 0; i <= _items.length - 1; i++) {
      _animatedList.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return Container();
      });
    }
    _items.clear();
  }

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
