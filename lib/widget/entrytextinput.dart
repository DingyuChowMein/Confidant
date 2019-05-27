import 'package:flutter/material.dart';

class EntryTextInput extends StatelessWidget {
  TextFormField textFormField;

  EntryTextInput({this.textFormField});

  @override
  Widget build(BuildContext context) {
    ///double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    double fontSize = Theme.of(context).textTheme.body1.fontSize; /// devicePixelRatio;
    num width;
    num height;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      return Container(
        //padding: EdgeInsets.all(15),
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
                              Expanded(child: textFormField),
                            ]),
                        painter:
                            EntryTextInputPainter(height, width, fontSize))))),
      );
    });
  }
}

class EntryTextInputPainter extends CustomPainter {
  num height;
  num width;
  num fontSize;

  EntryTextInputPainter(this.height, this.width, this.fontSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 1
      ..color = Colors.grey;

    /*TextSpan ts = new TextSpan(text: 'a', style: TextStyle(fontSize: 24));
    TextPainter tp = new TextPainter(text: ts, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    double plusser = tp.size.height;*/ // this returns 28

    for (double h = 0; h < 10000; h += fontSize + 4) {
      canvas.drawLine(Offset(0, h), Offset(width, h), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
