import 'package:first_app/helpers/query_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeController extends GetxController {
  RxBool isRecording = false.obs;
  RxString userPrompt = "".obs;
  RxList<String> intents = <String>[].obs;
  RxString answer = "".obs;
  RxBool isQueryReady = false.obs;
  RxBool isAnswerReady = false.obs;
  late Rx<BuildContext> context;
  Rx<AnswerState> ansState = AnswerState.Error.obs;
  RxBool micTurnedOn = false.obs;
  Rx<SpeechToText> speech = SpeechToText().obs;
  RxBool isSTTinit = false.obs;
  RxBool isAvailable = false.obs;

  updateIsAvailable(bool value) {
    isAvailable.value = value;
  }

  updateIsSTTinit(bool value) {
    isSTTinit.value = value;
  }

  initBuildContext(BuildContext value) {
    context.value = value;
  }

  updateRecordingStatus(bool value) {
    isRecording.value = value;
    update();
  }

  updateIntents(List<String> value) {
    intents.value = value;
    isQueryReady.value = true;
    update();
  }

  Future<void> updateUserPrompt(String value) async {
    userPrompt.value = value;
    print(userPrompt.value);
    update();
  }

  updateIsQueryReady(bool value) {
    isQueryReady.value = value;
    update();
  }

  Future<void> updateIsAnswerReady(bool value) async {
    isAnswerReady.value = value;
    print("answer ready: ${isAnswerReady.value}");
  }

  updateAnswer(String value) {
    answer.value += value;
    update();
  }

  resetAnswer() {
    answer.value = "";
    update();
  }

  updateAnsState(AnswerState value) {
    ansState.value = value;
  }

  updateMicTurnedOn(bool value) {
    micTurnedOn.value = value;
  }
}
