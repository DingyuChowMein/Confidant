// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:confidant/page/list.dart';
import 'package:confidant/page/entrypage.dart';
import 'package:confidant/widget/entrytextinput.dart';

import 'package:confidant/main.dart';

void main() {
  /*// Build our app and trigger a frame.
    await tester.pumpWidget(Confidant());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);*/

  testWidgets('new entry page starts with "Untitled"',
      (WidgetTester tester) async {
    Widget newEntryPageWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home: EntryPage.newEntry()));

    await tester.pumpWidget(newEntryPageWidget);

    expect(find.text('Untitled'), findsOneWidget);
  });

  testWidgets('new entry page starts with empty body',
      (WidgetTester tester) async {
    Widget newEntryPageWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home: EntryPage.newEntry()));

    await tester.pumpWidget(newEntryPageWidget);

    expect(find.text(''), findsOneWidget);
  });

  testWidgets(
      'entrytextinput takes available vertical space, and all horizontal space',
      (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();

    await binding.setSurfaceSize(Size(1280, 720));

    Widget newEntryPageWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home: EntryPage.newEntry()));

    await tester.pumpWidget(newEntryPageWidget);

    Size appbarSize = tester.getSize(find.byType(AppBar));
    Size textEntrySize = tester.getSize(find.byType(EntryTextInput));
    Size bottomBarSize = tester.getSize(find.byType(BottomAppBar));
    expect(
        appbarSize.height + textEntrySize.height + bottomBarSize.height, 720);
    expect(textEntrySize.width, 1280);
  });
}
