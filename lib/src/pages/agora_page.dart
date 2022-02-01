import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtcRemoteView;
import 'package:dostop_v2/src/providers/notificaciones_provider.dart';
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/utils/preferencias_usuario.dart';
import 'package:dostop_v2/src/utils/utils.dart' as utils;
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as toast;
import 'package:dostop_v2/src/widgets/countdown_timer.dart';
import 'package:dostop_v2/src/widgets/elevated_container.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraPage extends StatefulWidget {
  final String channelCall; 
  final String appIdAgora;
  final String idVisita;
  final DateTime fecha;
  AgoraPage({Key key, @required this.channelCall, @required this.appIdAgora, this.idVisita, this.fecha}) : super(key: key);

  @override
  _AgoraPageState createState() => _AgoraPageState();
}

class _AgoraPageState extends State<AgoraPage> {
  final _serviceCall = VisitasProvider();
  final _notifProvider = NotificacionesProvider();
  final _prefs = PreferenciasUsuario();
  bool _respuestaEnviada = false, _tiempoVencido = false;
  int _remoteUid;
  bool _localUserJoined = false;
  bool muted = false;
  bool mutedVideo = false;
  RtcEngine _engine;
  DateTime fecha;

  @override
  void initState() {
    super.initState();
    initAgora();
    DateTime fechaVisita = widget.fecha;
    fecha = widget.fecha == null
        ? DateTime.now()
        : fechaVisita.add(Duration(minutes: 1));
  }

  Future<void> initAgora() async {
    if (Platform.isAndroid) {
      await Permission.microphone.request();
    }
    //create the engine
    _engine = await RtcEngine.create(widget.appIdAgora);

    await _engine.enableVideo();
    await _engine.enableAudio();
    _engine.muteLocalVideoStream(true);
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(null, widget.channelCall, null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: utils.appBarLogo(titulo: 'Visita', backbtn: null),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: _remoteVideo(),
                    ),
                    _toolbar(widget.idVisita),
                    Padding(
                padding: EdgeInsets.all(15.0),
                child: AnimatedCrossFade(
                  duration: Duration(milliseconds: 200),
                  crossFadeState: !_tiempoVencido
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Tiempo para responder '),
                      CountdownTimer(
                          showZeroNumbers: false,
                          endTime: fecha.millisecondsSinceEpoch,
                          secSymbol: '',
                          textStyle: utils.estiloBotones(18,
                              color:
                                  Theme.of(context).textTheme.bodyText2.color),
                          onEnd: () {
                            setState(() => _tiempoVencido = true);
                            _onCallEnd(context, widget.idVisita);
                          }),
                      Text(' seg'),
                    ],
                  ),
                  secondChild: Text(
                    'El tiempo para responder esta visita ha expirado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: utils.colorToastRechazada,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _toolbar(String idVisita) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _crearBtnRespuesta(
                  titulo: 'Aceptar', idRespuesta: 1, idVisita: idVisita),
              _crearBtnRespuesta(
                  titulo: 'Rechazar', idRespuesta: 2, idVisita: idVisita),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RawMaterialButton(
                onPressed: () => _onToggleMute(),
                child: new Icon(
                  muted ? Icons.mic : Icons.mic_off,
                  color: muted ? Colors.white : utils.colorPrincipal,
                  size: 35.0,
                ),
                shape: new CircleBorder(),
                elevation: 8.0,
                fillColor: muted ? utils.colorPrincipal : Colors.white,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: () => _onCallEnd(context, idVisita),
                child: new Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: new CircleBorder(),
                elevation: 8.0,
                fillColor: utils.colorToastRechazada,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: () => _onToggleMuteVideo(),
                child: new Icon(
                  mutedVideo
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  color: mutedVideo ? Colors.white : utils.colorPrincipal,
                  size: 35.0,
                ),
                shape: new CircleBorder(),
                elevation: 8.0,
                fillColor: mutedVideo ? utils.colorPrincipal : Colors.white,
                padding: const EdgeInsets.all(15.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });

    _engine.muteLocalAudioStream(muted);
  }

  void _onCallEnd(BuildContext context, String idVisita) {
    _serviceCall.serviceCall(idVisita, status: 0);
    Navigator.pop(context);
  }

  void _onToggleMuteVideo() {
    setState(() {
      mutedVideo = !mutedVideo;
    });

    _engine.muteAllRemoteVideoStreams(mutedVideo);
  }

  Widget _crearBtnRespuesta({
    String titulo,
    int idRespuesta,
    String idVisita,
  }) {
    return ElevatedContainer(
      child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: idRespuesta == 1
              ? utils.colorAcentuado
              : utils.colorToastRechazada,
          child: Container(
              alignment: Alignment.center,
              width: 100,
              height: 100,
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: utils.estiloTextoSombreado(22,
                    blurRadius: 6, offsetY: 3, dobleSombra: false),
              )),
          onPressed: _respuestaEnviada
              ? null
              : () {
                  setState(() {
                    _respuestaEnviada = true;
                  });
                  _notifProvider
                      .respuestaVisita(
                          _prefs.usuarioLogged, idVisita, idRespuesta)
                      .then((resp) {
                    toast.showToast(
                      resp['mensaje'],
                      backgroundColor: resp['id'] == '0'
                          ? idRespuesta == 1
                              ? utils.colorToastAceptada
                              : utils.colorToastRechazada
                          : null,
                      textStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, 'main', (route) => false);
                  });
                }),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return rtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return const Text(
        'Conectando...',
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }
}
