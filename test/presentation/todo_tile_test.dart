import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_todo/components/todo_tile.dart';

import '../helpers/mocks.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows the title and strikes it through when completed', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TodoTile(todo: todo(1, done: true), onToggle: () {}, onDelete: () {}),
      ),
    );

    final text = tester.widget<Text>(find.text('task 1'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('does not strike through an open task', (tester) async {
    await tester.pumpWidget(
      wrap(TodoTile(todo: todo(1), onToggle: () {}, onDelete: () {})),
    );

    final text = tester.widget<Text>(find.text('task 1'));
    expect(text.style?.decoration, isNull);
  });

  testWidgets('tapping the circle calls onToggle', (tester) async {
    var toggled = 0;
    await tester.pumpWidget(
      wrap(TodoTile(todo: todo(1), onToggle: () => toggled++, onDelete: () {})),
    );

    await tester.tap(find.byIcon(Icons.check));

    expect(toggled, 1);
  });

  testWidgets('tapping the trash icon calls onDelete', (tester) async {
    var deleted = 0;
    await tester.pumpWidget(
      wrap(TodoTile(todo: todo(1), onToggle: () {}, onDelete: () => deleted++)),
    );

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));

    expect(deleted, 1);
  });

  testWidgets('swiping the tile calls onDelete', (tester) async {
    var deleted = 0;
    await tester.pumpWidget(
      wrap(TodoTile(todo: todo(1), onToggle: () {}, onDelete: () => deleted++)),
    );

    await tester.drag(find.byType(TodoTile), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(deleted, 1);
  });
}
