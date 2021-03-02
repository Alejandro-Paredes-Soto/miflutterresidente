import 'dart:async';
// import 'package:rxdart/rxdart.dart';

class MensajeStream {
  MensajeStream._internal();

  static final MensajeStream _instance = MensajeStream._internal();

  static MensajeStream get instancia {
    return _instance;
  }
   final _mensajesStreamController = StreamController<Map<String, dynamic>>.broadcast();
    Stream<Map<String, dynamic>> get mensajes => _mensajesStreamController.stream;

  void addMessage(Map<String, dynamic> msg) {
    _mensajesStreamController.sink.add(msg);
    return;
  }

  dispose() {
    _mensajesStreamController?.close();
  }
}