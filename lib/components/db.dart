import 'dart:convert';
import 'dart:io';
import 'package:first_app/helpers/query_helper.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../controllers/controllers.dart';
import '../helpers/helpers.dart';

class DbModule {
  late final Database db;
  HomeController homeController = Get.find();

  initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "eva.db");

// Check if the database exists
//     var exists = await databaseExists(path);
    var exists = false;
    if (!exists) {
// Should happen only the first time you launch your application
      print("Creating new copy from asset");

// Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

// Copy from asset
      ByteData data = await rootBundle.load(join("assets", "eva.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

// Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

// open the database
    db = await openDatabase(path, readOnly: true);
  }

  testDB() async {
    var res =
        await db.rawQuery("select answer from canteen where query='time';");
    print(res);
    var queryRes = res.first;
    if (queryRes['answer'] != null) {
      homeController.updateAnswer(queryRes['answer']!.toString());
      print(homeController.answer.value);
      await homeController.updateIsAnswerReady(true);
    }
  }

  getAnswerFromDB(List<String> intents) async {
    if (intents.contains('general conversation')) {
      await getSmartReply(intents);
      return;
    }
    var queryString = "";
    if (tables.contains(intents[0]) && queries.contains(intents[1])) {
      queryString =
          "select answer from ${intents[0]} where query='${intents[1]}';";
    } else if (tables.contains(intents[1]) && queries.contains(intents[0])) {
      queryString =
          "select answer from ${intents[1]} where query='${intents[0]}';";
    }

    if (queryString != "") {
      print(queryString);
      var res = await db.rawQuery(queryString);
      print(res);
      if (res.isEmpty) {
        homeController.updateAnsState(AnswerState.Error);
        homeController.updateAnswer('SORRY I CANNOT ANSWER YOU');
        await homeController.updateIsAnswerReady(true);
      } else {
        var queryRes = res.first;
        homeController.updateAnswer(
            queryRes['answer'].toString() ?? 'SORRY I CANNOT ANSWER YOU');
        print(homeController.answer.value);
        if (homeController.answer.value.length < 100) {
          homeController.updateAnsState(AnswerState.Available);
        } else {
          homeController.updateAnsState(AnswerState.Generic);
        }
        await homeController.updateIsAnswerReady(true);
        print("DB RES: ${queryRes["answer"] ?? 'SORRY I CANNOT ANSWER YOU'}");
      }
    } else {
      homeController.updateAnsState(AnswerState.Error);
      homeController.updateAnswer('Sorry i cannot answer you');
      await homeController.updateIsAnswerReady(true);
    }
  }

  Future<void> getSmartReply(List<String> intents) async {
    //p
    var payloadRaw = {
      "inputs": {
        "past_user_inputs": [],
        "generated_responses": [],
        "text": homeController.userPrompt.value
      }
    };
    var payload = jsonEncode(payloadRaw);
    var url = Uri.parse(
        "https://api-inference.huggingface.co/models/microsoft/DialoGPT-large");
    var response = await http.post(url,
        headers: {
          "Authorization": "Bearer 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"
        },
        body: payload);

    Map<String, dynamic> DialoRes = jsonDecode(response.body);
    if (DialoRes.containsKey('generated_text')) {
      homeController.updateAnswer(DialoRes['generated_text']);
      homeController.updateAnsState(AnswerState.Available);
      await homeController.updateIsAnswerReady(true);
    } else {
      homeController.updateAnsState(AnswerState.Error);
      homeController.updateAnswer('Sorry I cannot answer you');
      await homeController.updateIsAnswerReady(true);
    }
  }
}
