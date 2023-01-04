import 'dart:convert';
import 'dart:developer';

import 'package:dostop_v2/src/models/questions_model.dart';
export 'package:dostop_v2/src/models/questions_model.dart';
import 'login_validator.dart';
import 'package:http/http.dart' as http;

class QuestionsProvider {
  final validaSesion = LoginValidator();

  Future<List<QuestionModel>> cargaQuestions() async {
    log('cargando preguntas');
    try {
      final resp = await http.get(
        Uri.parse(
            'http://192.168.100.9/integracionpd/public/api/v1/suport/all/'),
      );
      Map? decodeResp = json.decode(resp.body);
      if (decodeResp!.containsKey('FAQ')) {
        var resp = decodeResp['FAQ'];
        final List<QuestionModel> questions = [];
        resp.forEach((question) {
          final tempAviso = QuestionModel.fromJson(question);
          questions.add(tempAviso);
        });
        return questions;
      }
      return [];
    } catch (e) {
      print('Ocurrió un error en la llamada al Servicio de QUESTIONS:\n $e');
      return [];
    }
  }
}
