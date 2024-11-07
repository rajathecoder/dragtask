import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();
  int? draggingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return Draggable<int>(
            data: index,
            feedback: Transform.scale(
              scale: 1.2,
              child: widget.builder(item),
            ),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: widget.builder(item),
            ),
            onDragStarted: () => setState(() {
              draggingIndex = index;
            }),
            onDraggableCanceled: (_, __) => setState(() {
              draggingIndex = null;
            }),
            onDragCompleted: () => setState(() {
              draggingIndex = null;
            }),
            child: DragTarget<int>(
              onAccept: (fromIndex) {
                setState(() {
                  final movedItem = _items.removeAt(fromIndex);
                  _items.insert(index, movedItem);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: draggingIndex == index
                      ? const SizedBox.shrink()
                      : widget.builder(item),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
