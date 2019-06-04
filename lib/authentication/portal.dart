import 'package:flutter/material.dart';
import 'package:confidant/page/listpage.dart';
import 'package:confidant/authentication/signin.dart';
import 'package:confidant/authentication/signoutoronlineentrylist.dart';
import 'package:confidant/authentication/auth.dart';

const String UNCHANGED_LOGIN_POP = "#";
const String LOGGED_OUT_POP = ".";

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.list});

  final BaseAuth auth;
  ListPage list;

  @override
  State<StatefulWidget> createState() =>
      new _RootPageState(auth: auth);
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = UNCHANGED_LOGIN_POP;
  BaseAuth auth;

  _RootPageState({this.auth});

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onSignedIn() {
    //authStatus = AuthStatus.LOGGED_IN;
    // todo: display login successful toast or something
  }

  void _onSignedOut() {
    //authStatus = AuthStatus.NOT_LOGGED_IN;
    Navigator.pop(context, LOGGED_OUT_POP);
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onSignedIn,
        );
        break;
      case AuthStatus.LOGGED_IN:
        return new SignoutPage(
          auth: widget.auth,
          onSignedOut: _onSignedOut,
          uid: _userId
        );
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
