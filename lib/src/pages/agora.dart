
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtcRemoteView;
import 'package:dostop_v2/src/providers/visitas_provider.dart';
import 'package:dostop_v2/src/utils/utils.dart';
import 'package:dostop_v2/src/widgets/countdown_timer.dart';

import 'package:flutter/material.dart';
import 'package:permissions_plugin/permissions_plugin.dart';

const appId = "42a83b0ca433486d96407c27a816e102";

class Agora extends StatefulWidget {
  Agora({Key key}) : super(key: key);

  @override
  _AgoraState createState() => _AgoraState();
}

class _AgoraState extends State<Agora> {
  final _serviceCall = VisitasProvider();
  int _remoteUid;
  bool _localUserJoined = false;
  bool muted = true;
  bool mutedVideo = false;
  bool _tiempoVencido = false;
  RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    //create the engine
    _engine = await RtcEngine.create(appId);
    _engine.muteLocalVideoStream(true);
    
    await _engine.enableVideo();
    _engine.muteLocalAudioStream(true);
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(null, "prueba", null, 0);
  }

  @override
  Widget build(BuildContext context) {
    var arg = ModalRoute.of(context).settings.arguments as List;
    DateTime fecha = arg[0] == null ? DateTime.now() : arg[0].add(Duration(minutes: 1));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      body: Column(
        children: [
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
                    textStyle: estiloBotones(18,
                        color: Theme.of(context).textTheme.bodyText2.color),
                    onEnd: () {
                      setState(() => _tiempoVencido = true);
                      _onCallEnd(context, arg[1]);
                    } 
                  ),
                  Text(' seg'),
                ],
              ),
              secondChild: Text(
                'El tiempo para responder esta visita ha expirado',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colorToastRechazada,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
              child: Stack(
              children: [
                Center(
                  child: _remoteVideo(),
                ),
                _toolbar(arg[1])
              ],
            ),
          ),
        ],
      ),
      
    ));
  }

  Widget _toolbar(String idVisita){
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () => _onToggleMute(),
            child: new Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : colorPrincipal,
              size: 35.0,
            ),
            shape: new CircleBorder(),
            elevation: 8.0,
            fillColor: muted ? colorPrincipal : Colors.white,
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
		        fillColor: colorToastRechazada,
		        padding: const EdgeInsets.all(15.0),
		      ),

          RawMaterialButton(
            onPressed: () => _onToggleMuteVideo(),
            child: new Icon(
              mutedVideo ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              color: mutedVideo ? Colors.white : colorPrincipal,
              size: 35.0,
            ),
            shape: new CircleBorder(),
            elevation: 8.0,
            fillColor: mutedVideo ? colorPrincipal : Colors.white,
            padding: const EdgeInsets.all(15.0),
          ),

        ],
      ),
    );
  }

  void _onToggleMute(){
    setState(() {
      muted = !muted;
    });

    _engine.muteLocalAudioStream(muted);
  }

  void _onCallEnd(BuildContext context, String idVisita){
    _serviceCall.serviceCall(idVisita, status: 0);
    Navigator.pop(context);
  }

  void _onToggleMuteVideo(){
    setState(() {
      mutedVideo = !mutedVideo;
    });

    _engine.muteAllRemoteVideoStreams(mutedVideo);
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
