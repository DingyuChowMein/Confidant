import 'package:flutter/material.dart';

//  anger, fear, joy, sadness; analytical, confident, tentative

abstract class Emotion {
  Color colour;
  String name;
  double intensity;
  Emotion(this.colour, this.name, this.intensity);
}

class Anger extends Emotion {
  Anger(double intensity) : super(Colors.red, "anger", intensity);
}

class Fear extends Emotion {
  Fear(double intensity) : super(Colors.lightGreen, "fear", intensity);
}

class Joy extends Emotion {
  Joy(double intensity) : super(Colors.yellow, "joy!", intensity);
}

class Sadness extends Emotion {
  Sadness(double intensity) : super(Colors.blue, "sadness", intensity);
}

class Analytical extends Emotion {
  Analytical(double intensity) : super(Colors.brown, "analytical", intensity);
}

class Confident extends Emotion {
  Confident(double intensity) : super(Colors.indigo, "confident", intensity);
}

class Tentative extends Emotion {
  Tentative(double intensity) : super(Colors.black, "tentative", intensity);
}

class EmotionSet {
  Anger anger;
  Fear fear;
  Joy joy;
  Tentative tentative;
  Confident confident;
  Analytical analytical;

  final List<Emotion> list = new List<Emotion>();

  EmotionSet({double angerIntensity = 0,
    double fearIntensity = 0,
    double joyIntensity = 0,
    double tentativeIntensity = 0,
    double confidentIntensity = 0,
    double analyticalIntensity = 0}) {

    this.anger = Anger(angerIntensity);
    this.fear = Fear(fearIntensity);
    this.joy = Joy(joyIntensity);
    this.tentative = Tentative(tentativeIntensity);
    this.confident = Confident(confidentIntensity);
    this.analytical = Analytical(analyticalIntensity);
    list
      ..add(anger)
      ..add(fear)
      ..add(joy)
      ..add(tentative)
      ..add(confident)
      ..add(analytical);
  }
}