import 'package:flutter/material.dart';
import 'package:confidant/emotion/tonejson.dart';
import 'dart:math';

//  anger, fear, joy, sadness; analytical, confident, tentative

const double DEFAULT_EMOTIONAL_INTENSITY = 1;

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
      {double angerIntensity = DEFAULT_EMOTIONAL_INTENSITY,
      double fearIntensity = DEFAULT_EMOTIONAL_INTENSITY,
      double joyIntensity = DEFAULT_EMOTIONAL_INTENSITY,
      double sadnessIntensity = DEFAULT_EMOTIONAL_INTENSITY,
      double tentativeIntensity = DEFAULT_EMOTIONAL_INTENSITY,
      double confidentIntensity = DEFAULT_EMOTIONAL_INTENSITY,
      double analyticalIntensity = DEFAULT_EMOTIONAL_INTENSITY}) {
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

    double angerAccumulator = DEFAULT_EMOTIONAL_INTENSITY;
    double fearAccumulator = DEFAULT_EMOTIONAL_INTENSITY;
    double sadnessAccumulator = DEFAULT_EMOTIONAL_INTENSITY;
    double joyAccumulator = DEFAULT_EMOTIONAL_INTENSITY;
    double tentativeAccumulator = DEFAULT_EMOTIONAL_INTENSITY;
    double confidentAccumulator = DEFAULT_EMOTIONAL_INTENSITY;
    double analyticalAccumulator = DEFAULT_EMOTIONAL_INTENSITY;

    if (ea.sentences != null) {
      //print('got null');
      List<SentenceTone> sentences = ea.sentences;

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
    } else {
      //print('got here');
      DocumentTone docTone = ea.docTone;
      for (IndividualTone t in docTone.tones) {
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
