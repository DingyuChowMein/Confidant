import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:confidant/page/entrypage.dart';
import 'package:confidant/page/pinpage.dart';
import 'package:confidant/data/database.dart';
import 'package:confidant/widget/scopebase.dart';
import 'package:confidant/widget/emotiveface.dart';
import 'package:confidant/widget/radarlove.dart';
import 'package:confidant/authentication/portal.dart';
import 'package:confidant/authentication/auth.dart';
import 'package:confidant/emotion/emotions.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'dart:async';
import 'dart:math';

class ListPage extends StatefulWidget {
  ListPage({Key key}) : super(key: key);
  final Auth auth = new Auth();

  @override
  _ListPageState createState() => _ListPageState(auth);
}

class _ListPageState extends State<ListPage> {
  // ensures only one slidable can be open at a time
  final SlidableController slidableController = SlidableController();
  String userId = LOGGED_OUT_POP;
  final Auth auth;

  _ListPageState(this.auth);

  FirebaseDatabase _fdb = FirebaseDatabase.instance;
  SharedPreferences prefs;

  void _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _signInOrUp() async {
    String tempUserId = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => new RootPage(auth: auth)));
    // '#' means no change to username
    // '.' means signed out
    if (tempUserId != UNCHANGED_LOGIN_POP && tempUserId != null) {
      userId = tempUserId;
      print("updated userId to " + tempUserId);
    }
  }

  void _setPin() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => new PinPage()));
  }

  void _getCurrentUser() {
    userId = LOGGED_OUT_POP;
    auth.getCurrentUser().then((user) {
      if (user != null) {
        userId = user?.uid;
        print("user logged in as: " + userId);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentUser();
    ScopeBaseWidget.of(context).bloc.refresh();
    return Scaffold(
      appBar: AppBar(
          /** TODO: DYNAMIC FACE; use setState() **/
          leading: Container(
              child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: FlatButton(
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset('assets/logo.png'),
                      onPressed: () => showAboutDialog(
                          context: context,
                          applicationIcon: Icon(Icons.tag_faces),
                          applicationName: 'Confidant',
                          applicationLegalese:
                              "Made by Neil Sayers, Maëlhann Rozé, Dingyu Chen, and Nathan Foulsham.",
                          applicationVersion: '0.0.1')))),
          title: const Text('Confidant'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.color_lens),
              /**TODO: COLOUR PICKER STUFF**/
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.vpn_key),
              onPressed: _setPin,
            ),
            IconButton(icon: Icon(Icons.cloud), onPressed: _signInOrUp),
          ]),
      body: Container(
          child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Entry>>(
                stream: ScopeBaseWidget.of(context).bloc.listStream,
                builder: (context, snapshot) {
                  if (snapshot.data == null || snapshot.data.length == 0)
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Text('		you have no entries',
                          style: TextStyle(fontSize: 20, color: Colors.grey)),
                    );
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, i) => EntryListItem(
                          entry: snapshot.data[i],
                          userId: userId,
                          controller: slidableController,
                          prefs: prefs,
                        ),
                  );
                }),
          ),
          // Divider(),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => EntryPage.newEntry())),
        child: Icon(
          Icons.add,
          color: Colors.yellow,
        ),
        foregroundColor: Colors.pink,
      ),
    );
  }

  @override
  void dispose() {
    ScopeBaseWidget.of(context).bloc.dispose();
    super.dispose();
  }
}

class EntryListItem extends StatelessWidget {
  final Entry entry;
  final String userId;
  final SlidableController controller;
  final SharedPreferences prefs;

  const EntryListItem(
      {Key key, this.entry, this.userId, this.controller, this.prefs})
      : super(key: key);

  String _getCorrectPin() {
    print("getting correct pin");
    String s = prefs.getString(ENTRY_PIN_PREF);
    print(s);
    return s;
  }

  Future<bool> _checkPinDialog(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Locked Entry: Enter PIN to Continue',
              style: Theme.of(context).textTheme.body2),
          content: Padding(
            padding: const EdgeInsets.all(0),
            child: Center(
                child: PinCodeTextField(
                    pinBoxWidth: 40,
                    pinBoxHeight: 40,
                    autofocus: true,
                    onDone: (String pinInput) {
                      Navigator.of(context).pop(pinInput == _getCorrectPin());
                    })),
          ),
        );
      },
    );
  }

  FutureOr<bool> _verifyDeletionIntention(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete', style: Theme.of(context).textTheme.body2),
          content: Text('Are you sure you\'d like to delete this entry?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
                entry.delete();
                ScopeBaseWidget.of(context).bloc.refresh();
              },
            ),
          ],
        );
      },
    );
  }

  void _uploadEntry(context) {
    if (userId == LOGGED_OUT_POP) {
      _loginToUpload(context);
    } else {
      entry.upload(userId);
    }
  }

  void _shareEntryToUser(context) {
    final emailFieldController = TextEditingController();
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Share', style: Theme.of(context).textTheme.body2),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(
                'To whom would you like to share this entry to? Type their Confidant account\'s email.'),
            Center(child: TextField(controller: emailFieldController))
          ]),
          actions: <Widget>[
            FlatButton(
              child: Text('Share'),
              onPressed: () {
                Navigator.of(context).pop();
                entry.shareTo(emailFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _shareEntry(context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Share', style: Theme.of(context).textTheme.body2),
          content: Text('How would you like to share this entry?'),
          actions: <Widget>[
            FlatButton(
              child: Text('To Another Confidant User'),
              onPressed: () {
                Navigator.of(context).pop();
                _shareEntryToUser(context);
              },
            ),
            FlatButton(
              child: Text('Elsewhere'),
              onPressed: () {
                Navigator.of(context).pop();
                Share.share(entry.body);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEmotionStats(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Stats', style: Theme.of(context).textTheme.body2),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            EmotionalRadarChart(
                emotionSet:
                    EmotionSet.fromAnalysis(entry.analyseWithPreexistingJson()))
          ]),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openEntry(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EntryPage(entry)));
  }

  void _checkPin(BuildContext context, Function(BuildContext) doAction) {
    var pinFromPrefs = _getCorrectPin();

    if (entry.pinProtected && pinFromPrefs != null) {
      _checkPinDialog(context).then((pinCorrect) {
        if (pinCorrect != null && pinCorrect) {
          doAction(context);
        } else {
          showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:
                    Text('Wrong PIN', style: Theme.of(context).textTheme.body2),
                content: Text('The PIN you entered was incorrect.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      });
    } else if (entry.pinProtected && pinFromPrefs == null) {
      showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('PIN Protected Entry',
                style: Theme.of(context).textTheme.body2),
            content: Text(
                'You need to set your PIN. Do this by pressing the key icon in the top right.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      doAction(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    int mentalState = -15 + (new Random()).nextInt(30);

    Emotion mainTone = entry.calcMainToneForList();

    //Color bgColour = _getEmotionColour(mentalState);

    return Slidable(
      key: ValueKey(entry.dateTime),
      dismissal: SlidableDismissal(
        dismissThresholds: <SlideActionType, double>{
          SlideActionType.secondary: 1.0
        },
        child: SlidableDrawerDismissal(),
        onWillDismiss: (actionType) {
          if (entry.pinProtected) {
            _checkPinDialog(context).then((pinCorrect) {
              if (pinCorrect != null && pinCorrect)
                return _verifyDeletionIntention(context);
            });
          } else {
            return _verifyDeletionIntention(context);
          }
        },
        onDismissed: (actionType) {
          //if (actionType == SlideActionType.primary) {
          //          // ...
        },
      ),
      controller: controller,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.2,
      child: Container(
        color: mainTone.colour,
        child: ListTile(
          leading: Container(
              height: 30,
              width: 30,
              child:
                  entry.pinProtected ? Icon(Icons.lock) : Text(mainTone.emoji)),
          //: EmotiveFace(mentalState)),
          title: Text(entry.title, style: Theme.of(context).textTheme.body2),
          subtitle: Text(entry.dateTime.substring(0, NUM_CHARS_IN_DATE),
              style: Theme.of(context).textTheme.subtitle),
          onTap: () => _checkPin(context, _openEntry),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => _checkPin(context, _verifyDeletionIntention))
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'Upload',
            color: Colors.blue,
            icon: Icons.cloud_upload,
            // UPLOADS ENTRY
            onTap: () => _checkPin(context, _uploadEntry)),
        IconSlideAction(
            caption: 'Share',
            color: Colors.lightGreen,
            icon: Icons.share,
            // SHARES ENTRY
            onTap: () => _checkPin(context, _shareEntry)),
        IconSlideAction(
          caption: 'Stats',
          color: Colors.blueGrey,
          icon: Icons.tag_faces,
          onTap: () => _checkPin(context, _showEmotionStats),
        ),
      ],
    );
  }

  void _loginToUpload(context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text('Not Logged In', style: Theme.of(context).textTheme.body2),
          content: Text('Please login to upload your note.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
