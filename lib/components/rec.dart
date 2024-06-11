import 'dart:convert';
import 'dart:typed_data';
import 'package:first_app/components/db.dart';
import 'package:first_app/controllers/controllers.dart';
import 'package:first_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';

import 'bart_payload.dart';

class Rec {
  Rec({required this.context}) {
    initRecorder().then((value) {
      print("Initialized");
    });
  }

  final BuildContext context;
  final HomeController homeController = Get.find();
  SpeechToText speech = SpeechToText();
  final DbModule dbModule = DbModule();

  bool _isRec = false;
  late Uint8List contents;

  // late final FlutterAudioRecorder2 recorder;

  //Todo: add init function
  initRecorder() async {
    if (!homeController.isSTTinit.value) {
      var available = await speech.initialize(
        //initializing STT
        onStatus: (status) {},
        onError: (result) {},
      );
      print("STT Initializing");
      homeController.updateIsSTTinit(true);
      homeController.updateIsAvailable(available);
    }

    dbModule.initDB();
  }

  recordMic() async {
    //then async await
    _isRec = !(_isRec);
    print("Starting record");
    if (_isRec) {
      homeController.resetAnswer();
      print("Recording");
      if (homeController.isAvailable.value) {
        await speech.listen(
            partialResults: false,
            listenMode: ListenMode.dictation,
            onResult: (result) async {
              await homeController.updateUserPrompt(result.recognizedWords);
            });
      } else {
        print("speech recognition not available.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("speech recognition not available")));
      }
      // some time later...

      // await recorder.start();
      homeController.updateIsQueryReady(false);
      homeController.isAnswerReady(false);
      //print('tempPath/myFile.m4a');
    }
    if (!_isRec) {
      print("stopping rec..");
      await speech.stop();
      await Future.delayed(Duration(seconds: 3));
      print("stopped rec..");

      print(homeController.userPrompt.value);
      if (homeController.userPrompt.value.isNotEmpty) {
        // var bartUrl = Uri.parse(
        //     "https://api-inference.huggingface.co/models/facebook/bart-large-mnli");
        var bartUrl = Uri.parse(
            "https://api-inference.huggingface.co/models/MoritzLaurer/DeBERTa-v3-base-mnli-fever-anli");
        var payloadRaw = {
          "inputs": homeController.userPrompt.value,
          "parameters": {
            "candidate_labels": intents,
          }
        };
        var payload = jsonEncode(payloadRaw);
        print(payload);
        var bartRes = await http.post(bartUrl,
            headers: {
              "Authorization": "Bearer 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"
            },
            body: payload);

        print(bartRes.body);
        Map<String, dynamic> bartBody = jsonDecode(bartRes.body);
        if (bartBody.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "DeBERTa is being initialized. Try again Please wait 20 secs",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: blue,
          ));
          print("API Error: API is being initialized. Please wait");

          await Future.delayed(Duration(seconds: 25));
          bartRes = await http.post(bartUrl,
              headers: {
                "Authorization": "Bearer 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"
              },
              body: payload);

          print(bartRes.body);
          bartBody = jsonDecode(bartRes.body);

          if (bartBody.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "DeBERTa is unavailable.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: blue,
            ));
            print("API Error: API is unavailable.");
            return;
          }
          // await dbModule.testDB();
        }
        var bartpayload = BartPayload.fromJson(jsonDecode(bartRes.body));
        var intentRes = bartpayload.labels;
        print(intentRes);
        if (intentRes != null) {
          homeController.updateIntents(intentRes.sublist(0, 2));
          await dbModule.getAnswerFromDB(intentRes.sublist(0, 2));
          // dbModule.testDB();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please try again.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: blue,
        ));
        print("Uninitialized");
      }
    }
  }
}
