import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:confidant/page/entrypage.dart';
import 'package:confidant/data/database.dart';
import 'package:confidant/widget/scopebase.dart';
import 'package:confidant/widget/emotiveface.dart';
import 'package:confidant/authentication/portal.dart';
import 'package:confidant/authentication/login.dart';
import 'package:confidant/authentication/auth.dart';
import 'dart:async';
import 'dart:math';



class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // ensures only one slidable can be open at a time
  final SlidableController slidableController = SlidableController();
  final String userId = "";
  bool LOGGED_IN = false;

  FirebaseDatabase _fdb = FirebaseDatabase.instance;
  Query _entryQuery;

  signIn() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new RootPage(auth: new Auth())));
    return result;
  }

  signOut() async {
    final result
  }



  @override
  Widget build(BuildContext context) {
    ScopeBaseWidget.of(context).bloc.refresh();
    return Scaffold(
      appBar: AppBar(
          /** TODO: DYNAMIC FACE; use setState() **/
          leading: EmotiveFace(15),
          title: const Text('Confidant Journal'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.color_lens),
              /**TODO: COLOUR PICKER STUFF**/
              onPressed: () {},
            ),
            // action button
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                if(!LOGGED_IN){
                signIn();
                }else{
                 signOut();
                }
              },
            ),
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
                      child: Text('Add Entries Here Tbh',
                          style: TextStyle(fontSize: 32, color: Colors.black)),
                    );

                  return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, i) => EntryListItem(
                          entry: snapshot.data[i],
                          controller: slidableController),
                    );

//                  else{
//                    StreamBuilder(
//                            stream: _entryQuery.onValue,
//                            builder: (context, snap) {
//                              if (snap.hasData
//                                  && !snap.hasError
//                                  && snap.data.snapshot.value != null) {
//                                DataSnapshot snapshot = snap.data.snapshot;
//                                List item = [];
//                                List _list = [];
//                                _list = snapshot.value;
//                                _list.forEach((f) {
//                                  if (f != null) {
//                                    item.add(f);
//                                  }
//                                }
//                                );
//
//                                return ListView.builder(
//                                  itemCount: item.length,
//                                  itemBuilder: (context, i) => EntryListItem(
//                                      entry: item[i],
//                                      controller: slidableController),
////                                return snap.data.snapshot.value == null
////                                    ? SizedBox()
////                                    : ListView.builder(
////                                  scrollDirection: Axis.horizontal,
////                                  itemCount: item.length,
////                                  itemBuilder: (context, index) {
////                                    item[index];
////                                  },
//
//
//                                );
//                              } else {
//                                return Center(child: CircularProgressIndicator());
//                            }
//                           }
//                           );
//
//                  }

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
  final SlidableController controller;

  const EntryListItem({Key key, this.entry, @required this.controller})
      : super(key: key);

  FutureOr<bool> _verifyDeletionIntention(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title: Text('Delete'),
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

  @override
  Widget build(BuildContext context) {
    final int mentalState = -15 + (new Random()).nextInt(30);
    final Color bgColour = Color.fromARGB(255, (184 - mentalState * 3.5).round(), (133 + mentalState * 27.25).round(), 99 + mentalState);

    return Slidable(
      key: ValueKey(entry.dateTime),
      dismissal: SlidableDismissal(
        dismissThresholds: <SlideActionType, double>{
          SlideActionType.secondary: 1.0
        },
        child: SlidableDrawerDismissal(),
        onWillDismiss: (actionType) {
          return _verifyDeletionIntention(context);
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
        /** TODO: DYNAMIC COLOUR **/
        color: bgColour,
        child: ListTile(
          leading:  Container(
              height: 40,
              width: 40,
              child: EmotiveFace(mentalState)
          ),
          title: Text(entry.title, style: Theme.of(context).textTheme.body2),
          subtitle: Text(entry.dateTime.substring(0, NUM_CHARS_IN_DATE),
              style: Theme.of(context).textTheme.subtitle),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => EntryPage(entry))),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              _verifyDeletionIntention(context);
            })
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Upload',
          color: Colors.blue,
          icon: Icons.share,
          // UPLOADS ENTRY
          onTap: () => {
          entry.upload(),
          },
        ),
        IconSlideAction(
          caption: 'Stats',
          color: Colors.blueGrey,
          icon: Icons.tag_faces,
          /** TODO: STATS STUFF **/
          onTap: () => {},
        ),
      ],
    );
  }
}
