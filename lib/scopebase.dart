import 'package:flutter/material.dart';
import 'entriesbloc.dart';

class ScopeBaseWidget extends InheritedWidget {
  final bloc = EntriesBLoC();
  final Widget child;
  ScopeBaseWidget({this.child});

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static ScopeBaseWidget of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(ScopeBaseWidget);

}