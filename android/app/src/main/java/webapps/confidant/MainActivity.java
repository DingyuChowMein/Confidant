package webapps.confidant;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }


  // Makes an API call providing emotional analysis on given text object
  private String makeAnalysisCall(Object obj) {
    String textToAnalyze = obj.toString();
    IamOptions options = new IamOptions.Builder()
            .apiKey("X0CnXwe429eh-ZgHkiduRutrd3DjP3x0kFH9qVovE4ze").build();

    ToneAnalyzer toneAnalyzer = new ToneAnalyzer("2019-05-23",options);
    toneAnalyzer
            .setEndPoint("https://gateway-lon.watsonplatform.net/tone-analyzer/api");

    ToneOptions toneOptions = new ToneOptions.Builder().text(textToAnalyze).build();
    ToneAnalysis toneAnalysis = toneAnalyzer.tone(toneOptions).execute().getResult();
    return toneAnalysis.getDocumentTone().toString();

  }

}
