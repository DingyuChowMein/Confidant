import 'package:flutter/material.dart';
import 'package:confidant/data/database.dart';
import 'package:confidant/emotion/tonejson.dart';
import 'package:confidant/emotion/emotions.dart';

class EntryTextInput extends StatelessWidget {
  static const double INSET_AMOUNT = 8.0;

  final TextFormField textFormField;
  final Entry entry;
  final bool highlightSentences;
  final ValueChanged<bool> onChanged;
  final FocusNode focusNode;

  EntryTextInput(
      {this.textFormField,
      this.entry,
      this.highlightSentences,
      this.onChanged,
      this.focusNode});

  void _handleTap() {
    onChanged(!highlightSentences);
  }

  List<TextSpan> _highlightedSentences(BuildContext context) {
    List<TextSpan> highlightedTextSpans = [];

    EmotionalAnalysis analysis = entry.analyseWithPreexistingJson();
    if (analysis == null) {
      print('sentence highlighting failed because analysis var was null');
      highlightedTextSpans.add(
          TextSpan(style: Theme.of(context).textTheme.body1, text: entry.body));
      return highlightedTextSpans;
    }

    List<SentenceTone> sentences = analysis.sentences;

    if (sentences == null) {
      // todo: pick biggest rather than first.
      Color docToneColour = analysis.docTone.tones.length > 0
          ? analysis.docTone.tones[0].emotion.colour
          : Emotionless().colour;

      highlightedTextSpans.add(TextSpan(
          text: entry.body,
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.body1.fontSize,
              backgroundColor: docToneColour)));
      return highlightedTextSpans;
    }

    Iterator<SentenceTone> sentenceListIter = sentences.iterator;
    Iterator<int> bodyIter = entry.body.codeUnits.iterator;

    Color previousColour = Colors.transparent;

    sentenceListIter.moveNext();
    while (bodyIter.moveNext()) {
      String ts = '';
      if (sentenceListIter.current.text.length == 0) {
        highlightedTextSpans.add(TextSpan(
            text: '\n',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.body1.fontSize)));
        sentenceListIter.moveNext(); // need false check???
        continue;
      }
      Iterator<int> sentIter = sentenceListIter.current.text.codeUnits.iterator;

      sentIter.moveNext();
      String tsBlank = '';
      while (bodyIter.current != sentIter.current) {
        tsBlank += String.fromCharCode(bodyIter.current);
        bodyIter.moveNext();
      }
      highlightedTextSpans.add(TextSpan(
          text: tsBlank,
          style: TextStyle(
              backgroundColor: previousColour,
              fontSize: Theme.of(context).textTheme.body1.fontSize)));

      while (bodyIter.current == sentIter.current) {
        ts += String.fromCharCode(bodyIter.current);

        if (!sentIter.moveNext()) {
          // todo: pick biggest rather than first
          Color sentenceColour = sentenceListIter.current.tones.length > 0
              ? sentenceListIter.current.tones[0].emotion.colour
              : Emotionless().colour;
          previousColour = sentenceColour;

          highlightedTextSpans.add(TextSpan(
              text: ts,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.body1.fontSize,
                  backgroundColor: sentenceColour)));

          if (!sentenceListIter.moveNext()) {
            return highlightedTextSpans;
          }
        } else {
          bodyIter.moveNext();
        }
      }
    }

    // SHOULDNT GET HERE
    return highlightedTextSpans;
  }

  Widget entryText(BuildContext context) {
    if (!highlightSentences) {
      //print("returning NOT highlighted sentneces");
      return unhighlightedSentences(context);
    }
    //print("returning highlighted sentneces");
    return GestureDetector(
        onTap: () => _handleTap(),
        // todo: whole screen container, rather than just covering text???
        child: Padding(
            padding: EdgeInsets.all(INSET_AMOUNT),
            child: RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.body1,
                    children: _highlightedSentences(context)))));
  }

  Widget unhighlightedSentences(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(INSET_AMOUNT), child: textFormField));
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild entry text");
    double fontSize = Theme.of(context).textTheme.body1.fontSize;
    num width;
    num height;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      return Container(
          height: double.infinity,
          child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                    child: CustomPaint(
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [entryText(context)]),
                        //children: [unhighlightedSentences(context)]),
                        painter:
                            EntryTextInputPainter(height, width, fontSize)))),
          ));
    });
  }
}

class EntryTextInputPainter extends CustomPainter {
  num height;
  num width;
  num fontSize;

  EntryTextInputPainter(this.height, this.width, this.fontSize);

  double _calcLineIncrementAmount() {
    TextSpan ts = TextSpan(text: 'a', style: TextStyle(fontSize: fontSize));
    TextPainter tp = TextPainter(
        text: ts, textAlign: TextAlign.left, textDirection: TextDirection.ltr)
      ..layout();
    return tp.size.height;
  }

  /*void paintHighlights(Canvas canvas, Size size) {
    EmotionalAnalysis


    List<int> codes = entry.body.codeUnits;
    var c;
    for (int i = 0; i < codes.length; i++)
      c = codes[i];


  }*/

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 1
      ..color = Colors.grey;

    double lineIncrementAmount = _calcLineIncrementAmount();

    for (double h = EntryTextInput.INSET_AMOUNT;
        h < 10000;
        h += lineIncrementAmount) {
      canvas.drawLine(Offset(0, h), Offset(width, h), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
