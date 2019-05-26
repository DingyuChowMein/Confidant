import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:confidant/pages/entrypage.dart';
import 'package:confidant/database/entry.dart';
import 'package:confidant/database/scopebase.dart';
import 'package:confidant/main.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // ensures only one slidable can be open at a time
  final SlidableController slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    ScopeBaseWidget.of(context).bloc.refresh();
    return Scaffold(
      appBar: AppBar(
          /** TODO: DYNAMIC FACE; use setState() **/
          leading: Icon(Icons.tag_faces),
          title: const Text('Confidant'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.color_lens),
              /** TODO: COLOUR PICKER STUFF**/
              onPressed: () {},
            ),
            // action button
            IconButton(
              icon: Icon(Icons.account_circle),
              /** TODO: LOGIN STUFF**/
              onPressed: () {},
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
                    itemBuilder: (context, i) =>
                        EntryListItem(entry: snapshot.data[i], controller: slidableController),
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
  final SlidableController controller;

  const EntryListItem({Key key, this.entry, @required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      controller: controller,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.2,
      child: Container(
        /** TODO: DYNAMIC COLOUR **/
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigoAccent,
            /** TODO: DYNAMIC FACE (and colours?)**/
            child: Icon(Icons.tag_faces),
            foregroundColor: Colors.white,
          ),
          title: Text(entry.title),
          subtitle: Text(entry.dateTime.substring(0, NUM_CHARS_IN_DATE)),
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
              entry.delete();
              ScopeBaseWidget.of(context).bloc.refresh();
            })
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Share',
          color: Colors.blue,
          icon: Icons.share,
          /** TODO: SHARE STUFF **/
          onTap: () => {},
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
