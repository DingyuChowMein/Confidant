import 'package:flutter/material.dart';
import 'package:confidant/emotion/tonejson.dart';
import 'dart:math';

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
  Sadness sadness;

  final List<Emotion> list = new List<Emotion>();

  EmotionSet(
      {double angerIntensity = 0,
      double fearIntensity = 0,
      double joyIntensity = 0,
      double sadnessIntensity = 0,
      double tentativeIntensity = 0,
      double confidentIntensity = 0,
      double analyticalIntensity = 0}) {
    this.anger = Anger(angerIntensity);
    this.fear = Fear(fearIntensity);
    this.joy = Joy(joyIntensity);
    this.tentative = Tentative(tentativeIntensity);
    this.confident = Confident(confidentIntensity);
    this.analytical = Analytical(analyticalIntensity);
    this.sadness = Sadness(sadnessIntensity);
    list
      ..add(anger)
      ..add(fear)
      ..add(joy)
      ..add(tentative)
      ..add(confident)
      ..add(analytical)
      ..add(sadness);
  }

  factory EmotionSet.fromAnalysis(EmotionalAnalysis ea) {
    if (ea == null) {
      return EmotionSet();
    }

    List<SentenceTone> sentences = ea.sentences;

    double angerAccumulator = 0;
    double fearAccumulator = 0;
    double sadnessAccumulator = 0;
    double joyAccumulator = 0;
    double tentativeAccumulator = 0;
    double confidentAccumulator = 0;
    double analyticalAccumulator = 0;

    for (SentenceTone s in sentences) {
      for (IndividualTone t in s.tones) {
        Emotion e = t.emotion;
        double intensity = e.intensity;
        switch (e.runtimeType) {
          case Anger:
            angerAccumulator += intensity;
            break;
          case Fear:
            fearAccumulator += intensity;
            break;
          case Joy:
            joyAccumulator += intensity;
            break;
          case Sadness:
            sadnessAccumulator += intensity;
            break;
          case Analytical:
            analyticalAccumulator += intensity;
            break;
          case Tentative:
            tentativeAccumulator += intensity;
            break;
          case Confident:
            confidentAccumulator += intensity;
            break;
          default:
            break;
        }
      }
    }

    return EmotionSet(
      analyticalIntensity: analyticalAccumulator,
      angerIntensity: angerAccumulator,
      joyIntensity: joyAccumulator,
      fearIntensity: fearAccumulator,
      confidentIntensity: confidentAccumulator,
      tentativeIntensity: tentativeAccumulator,
      sadnessIntensity: sadnessAccumulator,
    );
  }

  double maxValue() {
    List<double> intensities = list.map((e) => e.intensity).toList();
    return intensities.reduce(max);
  }
}
