import 'package:confidant/emotion/emotions.dart';

class EmotionalAnalysis {
  List<SentenceTone> sentences;
  DocumentTone docTone;

  EmotionalAnalysis({this.docTone, this.sentences});

  factory EmotionalAnalysis.fromJson(Map<String, dynamic> json) {
    var docTonesJson = json['document_tone'];

    var tempDocTone = DocumentTone.fromJson(docTonesJson);

    var sentencesTonesJson = json['sentences_tone'] as List;

    if (sentencesTonesJson != null) {
      List<SentenceTone> tempSentences = sentencesTonesJson
          .map<SentenceTone>((json) => SentenceTone.fromJson(json))
          .toList();
      return EmotionalAnalysis(docTone: tempDocTone, sentences: tempSentences);
    }
    return EmotionalAnalysis(docTone: tempDocTone);
  }

  @override
  String toString() {
    return docTone.toString() + '\n' + sentences.toString();
  }
}

class DocumentTone {
  List<IndividualTone> tones;

  DocumentTone({this.tones});

  factory DocumentTone.fromJson(Map<String, dynamic> json) {
    var tonesJson = json['tones'] as List;

    List<IndividualTone> tempTones = tonesJson
        .map<IndividualTone>((json) => IndividualTone.fromJson(json))
        .toList();

    return DocumentTone(tones: tempTones);
  }

  @override
  String toString() {
    String s = '';
    for (IndividualTone t in tones) {
      s += t.toString() + '\n';
    }
    return 'doc tone: \n' + s;
  }
}

class SentenceTone {
  int sentenceId;
  String text;
  List<IndividualTone> tones;

  SentenceTone({this.sentenceId, this.text, this.tones});

  factory SentenceTone.fromJson(Map<String, dynamic> json) {
    var tonesJson = json['tones'] as List;

    List<IndividualTone> tempTones = tonesJson
        .map<IndividualTone>((json) => IndividualTone.fromJson(json))
        .toList();

    return SentenceTone(
        sentenceId: json['sentence_id'], text: json['text'], tones: tempTones);
  }

  @override
  String toString() {
    String s = '';
    for (IndividualTone t in tones) {
      s += t.toString() + '\n';
    }
    return 'sentence id: $sentenceId. text: $text\n $s';
  }
}

class IndividualTone {
  final String toneId;
  final double intensity;

  Emotion emotion;

  IndividualTone({this.toneId, this.intensity}) {
    switch (toneId) {
      case 'sadness':
        emotion = Sadness(intensity);
        break;
      case 'analytical':
        emotion = Analytical(intensity);
        break;
      case 'joy':
        emotion = Joy(intensity);
        break;
      case 'anger':
        emotion = Anger(intensity);
        break;
      case 'confident':
        emotion = Confident(intensity);
        break;
      case 'fear':
        emotion = Fear(intensity);
        break;
      default:
        emotion = Anger(-1);
    }
  }

  factory IndividualTone.fromJson(Map<String, dynamic> json) {
    return IndividualTone(toneId: json['tone_id'], intensity: json['score']);
  }

  @override
  String toString() {
    return '====== ${emotion.name} ${emotion.intensity}';
  }
}
