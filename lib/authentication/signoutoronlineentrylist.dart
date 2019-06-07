import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:confidant/authentication/auth.dart';
import 'package:confidant/authentication/portal.dart';
import 'package:confidant/widget/radarlove.dart';
import 'package:confidant/data/database.dart';
import 'package:confidant/emotion/emotions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class SignoutPage extends StatefulWidget {
  SignoutPage({this.auth, this.onSignedOut, this.uid});

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String uid;

  @override
  State<StatefulWidget> createState() => new _SignoutPageState(uid);
}

class _SignoutPageState extends State<SignoutPage> {
  FirebaseDatabase _fdb = FirebaseDatabase.instance;
  final SlidableController slidableController = SlidableController();
  final String uid;

  _SignoutPageState(this.uid);

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
              Navigator.pop(context, UNCHANGED_LOGIN_POP);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: new Text('Your Cloud Entries!'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
          ],
        ));
  }

  Widget _showBody() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Flexible(
                child: FirebaseAnimatedList(
              query: FirebaseDatabase.instance.reference().child(uid),
              padding: EdgeInsets.all(20.0),
              reverse: false,
              itemBuilder: (context, snapshot, animation, index) => _buildItem(
                  context, snapshot, animation, index, slidableController),
            )),
            ListView(
              shrinkWrap: true,
              children: <Widget>[_showPrimaryButton()],
            )
          ],
        ));
  }

  FutureOr<bool> _verifyDeletionIntention(context, String dateTime) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete', style: Theme.of(context).textTheme.body2),
          content: Text(
              'Are you sure you\'d like to delete this entry from the cloud?'),
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
                // delete entry from db
                _fdb.reference().child(uid).child(dateTime).remove();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEmotionStats(BuildContext context, Entry entry) {
    bool pinProtected = entry.pinProtected;

    const String pinTitle = "Stats Unavailable";
    const String pinBody = "Entry is PIN protected.";

    Widget body = pinProtected
        ? Text(pinBody)
        : Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            EmotionalRadarChart(
                emotionSet:
                    EmotionSet.fromAnalysis(entry.analyseWithPreexistingJson()))
          ]);

    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(pinProtected ? pinTitle : 'Stats',
              style: Theme.of(context).textTheme.body2),
          content: body,
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

  Color _getEmotionColour(int mentalState, bool pinProtected) {
    if (pinProtected) {
      return Colors.white;
    }
    return Color.fromARGB(255, (184 - mentalState * 3.5).round(),
        (133 + mentalState * 27.25).round(), 99 + mentalState);
  }

  void _downloadEntry(DataSnapshot snapshot) {
    Entry e = Entry.fromSnapshot(snapshot);
    EntriesDatabase.get().insertOrUpdateEntry(e);
  }

  void _previewEntry(String title, String body, bool pinProtected) {
    const String pinTitle = "Preview Unavailable";
    const String pinBody = "Entry is PIN protected.";

    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text(pinProtected ? pinTitle : title,
              style: Theme.of(context).textTheme.body2),
          content: SingleChildScrollView(
            child: Text(pinProtected ? pinBody : body),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, DataSnapshot snapshot,
      Animation<double> animation, int index, SlidableController controller) {
    String title = snapshot.value[TITLE];
    String body = snapshot.value[BODY];
    bool pinProtected = snapshot.value[PIN_PROTECTED];
    String toneJsonString = snapshot.value[TONE_JSON];
    String dateTime = snapshot.key;

    Entry thisEntry = new Entry(
        dateTime: dateTime,
        title: title,
        body: body,
        pinProtected: pinProtected,
        toneJsonString: toneJsonString);
    final int mentalState = -15 + (new Random()).nextInt(30);

    Emotion mainTone = thisEntry.calcMainToneForList();
    //Color bgColour = _getEmotionColour(mentalState, pinProtected);

    return Slidable(
      key: ValueKey(dateTime),
      dismissal: SlidableDismissal(
        dismissThresholds: <SlideActionType, double>{
          SlideActionType.secondary: 1.0
        },
        child: SlidableDrawerDismissal(),
        onWillDismiss: (actionType) {
          return _verifyDeletionIntention(context, dateTime);
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
              child: pinProtected ? Icon(Icons.lock) : Text(mainTone.emoji)),
          //: EmotiveFace(mentalState)),
          title: Text(title, style: Theme.of(context).textTheme.body2),
          subtitle: Text(dateTime.substring(0, NUM_CHARS_IN_DATE),
              style: Theme.of(context).textTheme.subtitle),
          onTap: () {},
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _verifyDeletionIntention(context, dateTime),
        )
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Download',
          color: Colors.green,
          icon: Icons.cloud_download,
          onTap: () => _downloadEntry(snapshot),
        ),
        IconSlideAction(
          caption: 'Preview',
          color: Colors.amber,
          icon: Icons.pageview,
          onTap: () => _previewEntry(title, body, pinProtected),
        ),
        IconSlideAction(
          caption: 'Stats',
          color: Colors.blueGrey,
          icon: Icons.tag_faces,
          /** TODO: STATS STUFF **/
          onTap: () => _showEmotionStats(context, thisEntry)
        ),
      ],
    );

    /*return Card(
        color: Colors.brown,
        child: ListTile(
            title: Text(snapshot.value['title'])
        )
    );*/
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
