package webapps.confidant;

import android.os.Bundle;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.ibm.cloud.sdk.core.service.security.IamOptions;
import com.ibm.watson.tone_analyzer.v3.ToneAnalyzer;
import com.ibm.watson.tone_analyzer.v3.model.ToneAnalysis;
import com.ibm.watson.tone_analyzer.v3.model.ToneOptions;


public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "flutter.native/helper";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    // make native API call from method channel
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {


              // triggers Native API call when method "analyzeEntry" is called from
              // Dart file.
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("analyzeEntry")) {
                  String greetings = makeAnalysisCall(call.arguments());
                  result.success(greetings);
                }
              }});
  }


  // Makes an API call providing emotional analysis on given text object
  // Currently returns JSON as text.
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
