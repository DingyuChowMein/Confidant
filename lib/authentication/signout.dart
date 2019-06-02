import 'package:flutter/material.dart';
import 'package:confidant/authentication/auth.dart';
import 'package:confidant/page/list.dart';
import 'package:firebase_database/firebase_database.dart';

class SignoutPage extends StatefulWidget {
  SignoutPage({this.auth, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => new _SignoutPageState();
}

class _SignoutPageState extends State<SignoutPage> {
  FirebaseDatabase _database = FirebaseDatabase.instance;

  void _logOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: new AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  //widget.onSignedOut();
                  Navigator.pop(context, "#");
                },
                icon: Icon(Icons.arrow_back),
              ),
              title: new Text('Flutter logout basic'),
            ),
            body: Stack(
              children: <Widget>[
                _showBody(),
              ],
            ));
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[_showPrimaryButton()],
          ),
        ));
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.red,
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: _logOut),
        ));
  }
}
