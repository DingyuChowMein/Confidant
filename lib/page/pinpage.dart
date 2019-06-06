import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

const String ENTRY_PIN_PREF = "entry-pin";

class PinPage extends StatefulWidget {
  PinPage({Key key}) : super(key: key);

  @override
  _PinPageState createState() => _PinPageState();
}

enum PinMode { SET_PIN, SET_PIN_2, CHANGE_PIN }

class _PinPageState extends State<PinPage> {
  static const String NULL_PIN = "?";
  static const String SET_PIN_TITLE = "Set a new PIN!";
  static const String SET_PIN_2_TITLE = "Type that pin again!";
  static const String CHANGE_PIN_TITLE = "Type your old PIN";

  int keyNum = 1; // used to reset textfields on state sets
  String currentPin = NULL_PIN;
  String setPinStore = NULL_PIN;
  PinMode pinMode = PinMode.CHANGE_PIN;
  String title = CHANGE_PIN_TITLE;

  void _getCurrentPin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    currentPin = prefs.getString(ENTRY_PIN_PREF) ?? NULL_PIN;
    print('current pin: ');
    print(currentPin);

    setState(() {
      pinMode = (currentPin == NULL_PIN) ? PinMode.SET_PIN : PinMode.CHANGE_PIN;
      _updateTitle();
    });
  }

  void _setPin(String pinInput) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(ENTRY_PIN_PREF, pinInput);
  }

  void _updateTitle() {
    switch (pinMode) {
      case PinMode.SET_PIN:
        title = SET_PIN_TITLE;
        break;
      case PinMode.SET_PIN_2:
        title = SET_PIN_2_TITLE;
        break;
      case PinMode.CHANGE_PIN:
        title = CHANGE_PIN_TITLE;
        break;
    }
  }

  void _changeState(PinMode pinMode) {
    setState(() {
      keyNum++;
      this.pinMode = pinMode;
      _updateTitle();
    });
  }

  void _resetInput() {
    setState(() {
      keyNum++;
    });
  }

  Widget _showPinInput() {
    return PinCodeTextField(
        pinBoxHeight: 50,
        pinBoxWidth: 50,
        autofocus: true,
        onDone: (String pinInput) {
          switch (pinMode) {
            case PinMode.SET_PIN:
              setPinStore = pinInput;
              _changeState(PinMode.SET_PIN_2);
              break;
            case PinMode.SET_PIN_2:
              if (pinInput != setPinStore) {
                _changeState(PinMode.SET_PIN);
              } else {
                _setPin(pinInput);
                Navigator.of(context).pop();
              }
              break;
            case PinMode.CHANGE_PIN:
              if (pinInput == currentPin) {
                _changeState(PinMode.SET_PIN);
              } else {
                _resetInput();
              }
          }
        });
  }

  Widget _showBody() {
    return Scaffold(
        key: ValueKey(keyNum),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(title),
        ),
        body: Scaffold(
            body: Builder(
          builder: (context) => Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(child: _showPinInput()),
              ),
        )));
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPin();
  }

  @override
  Widget build(BuildContext context) {
    return _showBody();
  }
}
