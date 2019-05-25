import 'package:flutter/material.dart';

import 'main.dart';
import 'entry.dart';
import 'scopebase.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {

  @override
  Widget build(BuildContext context) {
    ScopeBaseWidget.of(context).bloc.refresh();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Confidant'),
      ),
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
                      child: Text(
                        'Add Your Notes Here',
                        style:  TextStyle(fontSize: 32, color: Colors.black)
                      ),
                    );
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, i) =>
                        EntryListItem(entry: snapshot.data[i]),
                  );
                }),
          ),
          // Divider(),
        ],
      )),
      /*Center(
        child: RaisedButton(
          child: Text('Make new note'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),*/
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

  const EntryListItem({Key key, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return EntryPage(entry);
          })),
      child: Row(
        children: <Widget>[
          Icon(Icons.accessible, color: Theme.of(context).iconTheme.color),
          SizedBox(width: 3),
          Text(entry.dateTime)
        ],
      ),
    );
  }
}
