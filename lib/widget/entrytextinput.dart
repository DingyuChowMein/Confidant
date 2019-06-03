import 'package:flutter/material.dart';

class EntryTextInput extends StatelessWidget {
  static const double INSET_AMOUNT = 8.0;
  TextFormField textFormField;

  EntryTextInput({this.textFormField});

  @override
  Widget build(BuildContext context) {
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
                            children: [
                              Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.all(INSET_AMOUNT),
                                      child: textFormField)),
                            ]),
                        painter: EntryTextInputPainter(
                            height, width, fontSize))))),
      );
    });
  }
}

class EntryTextInputPainter extends CustomPainter {
  num height;
  num width;
  num fontSize;

  EntryTextInputPainter(
      this.height, this.width, this.fontSize);

  double _calcLineIncrementAmount() {
    TextSpan ts = TextSpan(text: 'a', style: TextStyle(fontSize: fontSize));
    TextPainter tp = TextPainter(
        text: ts, textAlign: TextAlign.left, textDirection: TextDirection.ltr)
      ..layout();
    return tp.size.height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 1
      ..color = Colors.grey;

    double lineIncrementAmount = _calcLineIncrementAmount();

    for (double h = EntryTextInput.INSET_AMOUNT; h < 10000; h += lineIncrementAmount) {
      canvas.drawLine(Offset(0, h), Offset(width, h), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
