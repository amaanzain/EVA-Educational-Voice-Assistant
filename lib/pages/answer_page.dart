import 'package:first_app/controllers/controllers.dart';
import 'package:first_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import '../helpers/helpers.dart';

class AnswerPage extends StatelessWidget {
  AnswerPage({Key? key}) : super(key: key);

  final HomeController homeController = Get.find();
  final FlutterTts ftts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    if (homeController.ansState.value == AnswerState.Error) {
      ftts.speak("Sorry, I do not have the information to answer you");
    } else if (homeController.ansState.value == AnswerState.Generic) {
      ftts.speak("Here is what i found for your query");
    } else if (homeController.ansState.value == AnswerState.Available) {
      ftts.speak(homeController.answer.value);
    }
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background_img.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            Expanded(
              flex: 11,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("EVA",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Logo_Answer,
                              fontFamily: "Rubik Bold")),
                      Text(
                        "Educational Virtual",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 25,
                            color: Logo_Answer,
                            fontFamily: "Roboto Light"),
                      ),
                      Text(
                        "Assistant",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 25,
                            color: Logo_Answer,
                            fontFamily: "Roboto Light"),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () {
                          homeController.updateMicTurnedOn(true);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0x3d301356),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset("assets/mic_small.png"),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 20,
              child: Container(
                margin: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Color(0xff312052),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff301356), Color(0xff161225)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Text(homeController.userPrompt.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: "Poppins Light",
                                fontSize: 24,
                                color: Colors.grey)),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            homeController.answer.value,
                            style: const TextStyle(
                              fontFamily: "Poppins Light",
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
