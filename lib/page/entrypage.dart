import 'dart:async';

import 'package:flutter/material.dart';

import 'package:confidant/data/database.dart';
import 'package:confidant/widget/scopebase.dart';
import 'package:confidant/widget/radarlove.dart';
import 'package:confidant/widget/entrytextinput.dart';
import 'package:confidant/emotion/emotions.dart';
import 'package:confidant/emotion/tonejson.dart';
import 'package:speech_recognition/speech_recognition.dart';

class EntryPage extends StatefulWidget {
  EntryPage(this.entry);

  EntryPage.newEntry() : entry = new Entry();

  final Entry entry;

  @override
  _EntryPageState createState() => _EntryPageState(entry);
}

class _EntryPageState extends State<EntryPage> {
  Entry entry;
  EmotionalAnalysis analysis;
  bool highlightSentences = false;
  String mainToneString = '';
  FocusNode entryTextFocusNode = FocusNode();

  SpeechRecognition _speechRecognition = SpeechRecognition();
  bool _isAvailable = false;
  bool _isListening = false;
  String resultText = "";
  var _txt = TextEditingController();

  _EntryPageState(this.entry);

  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  var _formKey = GlobalKey<FormState>();

  void _saveEntry() {
    // calls 'validate' on all widgets in current state
    if (_formKey.currentState.validate()) {
      // calls 'save' on all widgets in current state
      _formKey.currentState.save();
      entry.save();
    }
  }

  void _analyseEntry() {
    if (_formKey.currentState.validate()) {
      print('analysing');
      // calls 'save' on all widgets in current state
      _formKey.currentState.save();
      entry.save();
      entry.analyse().then((analysisResult) {
        setState(() {
          analysis = analysisResult;
          mainToneString = "Overall: ${entry.calcMainTone(analysis).name}";
          highlightSentences = true;
        });
      });
    }
  }

  void speechToText() {
    if (_isAvailable && !_isListening) {
      _speechRecognition
          .listen(locale: "en_US")
          .then((result) => print('$result'));
    } else {
      stopRecording();
      _txt.value = new TextEditingController.fromValue(
              new TextEditingValue(text: resultText))
          .value;
    }
  }

  void stopRecording() {
    if (_isListening)
      _speechRecognition
          .stop()
          .then((result) => setState(() => _isListening = result));
  }

//  void cancelRecording() {
//    if (_isListening) {
//      _speechRecognition.cancel().then(
//            (result) => setState(() {
//                  _isListening = result;
//                  resultText = "";
//                }),
//          );
//    }
//  }

  @override
  void initState() {
    super.initState();
    if (entry.toneJsonString != '') {
      analysis = entry.analyseWithPreexistingJson();
      mainToneString = "Overall: ${entry.calcMainTone(analysis).name}";
    }
    _txt.text = entry.body;
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _saveEntry();
          ScopeBaseWidget.of(context).bloc.refresh();
          return true;
        },
        child: Form(
            key: _formKey,
            child: Scaffold(
              /** TODO: EMOTIONAL ANALYSIS INFO STUFF **/
              endDrawer: Drawer(
                  child: Column(children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(30),
                  child: Text('Emotional Analysis',
                      style: Theme.of(context).textTheme.headline),
                ),
                ListTile(title: Text(mainToneString), onTap: () {}),
                Center(
                  child: Container(
                    child: EmotionalRadarChart(
                      emotionSet: EmotionSet.fromAnalysis(analysis),
                    ),
                  ),
                ),
                /*Anger(0).toLegendWidget(),
                    Fear(0).toLegendWidget(),
                    Joy(0).toLegendWidget(),
                    Tentative(0).toLegendWidget(),
                    Confident(0).toLegendWidget(),
                    Analytical(0).toLegendWidget(),
                    Sadness(0).toLegendWidget(),*/
              ])),
              appBar: AppBar(
                title: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: TextFormField(
                              initialValue:
                                  entry.title == "" ? "Untitled" : entry.title,
                              onSaved: (s) => entry.title = s,
                              validator: (s) =>
                                  s.length > 2 ? null : 'Give it a title',
                              textCapitalization: TextCapitalization.sentences,
                              style: Theme.of(context).textTheme.title,
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              autofocus: true,
                            )),
                      )
                    ]),
              ),
              body: EntryTextInput(
                  onChanged: ((bool newValue) {
                    setState(() {
                      highlightSentences = newValue;
                    });
                  }),
                  entry: entry,
                  //focusNode: entryTextFocusNode,
                  highlightSentences: highlightSentences,
                  textFormField: TextFormField(
                    autofocus: true,
                    //focusNode: entryTextFocusNode,
                    controller: _txt,
                    //initialValue: entry.body,
                    onSaved: (s) => entry.body = s,
                    validator: (s) => s.length > 2 ? null : 'Give it a body',
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: Theme.of(context).textTheme.body1,
                    // must be same as theme used in painter
                    decoration: InputDecoration.collapsed(hintText: 'Type'),
                  )),
              bottomNavigationBar: BottomAppBar(
                color: Theme.of(context).buttonColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => speechToText(),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.mic,
                              color: Theme.of(context).iconTheme.color),
                          SizedBox(width: 3),
                          Text('Speak')
                        ],
                      ),
                    ),
//
//                    FloatingActionButton(
//                      onPressed: () => stopRecording(), //Save Button
//                      child: Row(
//                        children: <Widget>[
//                          Icon(Icons.stop,
//                              color: Theme.of(context).iconTheme.color),
//                          SizedBox(width: 3),
//                          Text('Stop ')
//                        ],
//                      ),
//                    ),
//                    FloatingActionButton(
//                      onPressed: () => cancelRecording(), //Save Button
//                      child: Row(
//                        children: <Widget>[
//                          Icon(Icons.mic,
//                              color: Theme.of(context).iconTheme.color),
//                          SizedBox(width: 3),
//                          Text('Cancel')
//                        ],
//                      ),                    ),
                    FlatButton(
                      onPressed: () {
                        _saveEntry();
                        _displaySaved();
                      }, //Save Button
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.save,
                              color: Theme.of(context).iconTheme.color),
                          SizedBox(width: 3),
                          Text('Save')
                        ],
                      ),
                    ),
//                    FlatButton(
//                      onPressed: () {
//                        return _verifyDeletionIntention(context);
//                      },
//                      child: Row(
//                        children: <Widget>[
//                          Icon(Icons.delete,
//                              color: Theme.of(context).iconTheme.color),
//                          SizedBox(width: 3),
//                          Text('Delete')
//                        ],
//                      ),
//                    ),

                    FlatButton(
                      onPressed: () => _analyseEntry(),
                      //onPressed: () => FocusScope.of(context).requestFocus(entryTextFocusNode),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.remove_red_eye,
                              color: Theme.of(context).iconTheme.color),
                          SizedBox(width: 3),
                          Text('Analyse')
                        ],
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                            entry.pinProtected ? Icons.lock : Icons.lock_open),
                        onPressed: () {
                          setState(() {
                            entry.pinProtected = !entry.pinProtected;
                          });
                        })
                  ],
                ),
              ),
            )));
  }

  void _displaySaved() {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Saved', style: Theme.of(context).textTheme.body2),
          content: Text('Your entry has been saved.'),
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

  void _verifyDeletionIntention(context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete', style: Theme.of(context).textTheme.body2),
          content: Text('Are you sure you\'d like to delete this entry?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                entry.delete();
                ScopeBaseWidget.of(context).bloc.refresh();
              },
            ),
          ],
        );
      },
    );
  }
}
