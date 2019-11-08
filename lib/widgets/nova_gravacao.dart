import 'dart:async';

import 'dart:convert';
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador/blocs/novo-iten-bloc.dart';
//import 'package:flutter_sound/flutter_sound.dart';
import 'package:gerenciador/screens/novo_item.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:permission_handler/permission_handler.dart';

class NovaGravacao extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  NovoItenBloc bloc;
  NovaGravacao({localFileSystem, bloc})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _NovaGravacaoState createState() => _NovaGravacaoState();
}

class _NovaGravacaoState extends State<NovaGravacao> {
  Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();

  final Stopwatch stopwatch = new Stopwatch();

//  FlutterSound flutterSound = new FlutterSound();
  // bool _isRecording = false;
  //bool _isPlaying = false;
  //StreamSubscription _recorderSubscription;
  //StreamSubscription _playerSubscription;

//  String _recorderTxt = '00:00:00';
  //String _path = '';

  // double _dbLevel;

  @override
  void initState() {
    super.initState();
    stopwatch.reset();
    //_recorderTxt = '00:00:00';
    // flutterSound = new FlutterSound();
    // flutterSound.setSubscriptionDuration(0.01);
    // flutterSound.setDbPeakLevelUpdate(0.8);
    // flutterSound.setDbLevelEnabled(true);
    // initializeDateFormatting();
  }

  // void startRecorder() async {
  //   try {
  //     _path = await flutterSound.startRecorder(getNomeCaminhoArquivoAudio());
  //     print('startRecorder: $_path');

  //     _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
  //       DateTime date = new DateTime.fromMillisecondsSinceEpoch(
  //           e.currentPosition.toInt(),
  //           isUtc: true);
  //       String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

  //       this.setState(() {
  //         this._recorderTxt = txt.substring(0, 8);
  //       });
  //     });

  //     this.setState(() {
  //       this._isRecording = true;
  //     });
  //   } catch (err) {
  //     print('startRecorder error: $err');
  //   }
  // }

  static final Random _random = Random.secure();

  static String CreateCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  String getNomeCaminhoArquivoAudio() {
    // String caminho = '/storage/emulated/0/default.m4a';
    return '/storage/emulated/0/' +
        'nat' +
        CreateCryptoRandomString(10) +
        'nat' +
        '.m4a';
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        // if (_controller.text != null && _controller.text != "") {
        //   String path = _controller.text;
        //   if (!_controller.text.contains('/')) {
        //     io.Directory appDocDirectory =
        //         await getApplicationDocumentsDirectory();
        //     path = appDocDirectory.path + '/' + _controller.text;
        //   }
        //   print("Start recording: $path");
        //   await AudioRecorder.start(
        //       path: path, audioOutputFormat: AudioOutputFormat.AAC);
        // } else {
        await AudioRecorder.start();
        //}
        bool isRecording = await AudioRecorder.isRecording;
        stopwatch.reset();
        setState(() {
          stopwatch.start();
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.microphone,PermissionGroup.storage]);

        // Scaffold.of(context).showSnackBar(
        //     new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print("  File length: ${await file.length()}");
    setState(() {
      stopwatch.stop();
      // _recorderTxt = recording.duration.toString();
      _recording = recording;
      _isRecording = isRecording;
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => NovoItem(
                  _recording.path,
                  _recording.duration.toString(),
                  null,
                  null,
                  widget.bloc,
                )));
  }

  // void stopRecorder() async {
  //   try {
  //     String result = await flutterSound.stopRecorder();
  //     print('stopRecorder: $result');

  //     if (_recorderSubscription != null) {
  //       _recorderSubscription.cancel();
  //       _recorderSubscription = null;
  //     }

  //     this.setState(() {
  //       this._isRecording = false;
  //     });
  //   } catch (err) {
  //     print('stopRecorder error: $err');
  //   }
  // }

  // void stopPlayer() async {
  //   try {
  //     String result = await flutterSound.stopPlayer();
  //     print('stopPlayer: $result');
  //     if (_playerSubscription != null) {
  //       _playerSubscription.cancel();
  //       _playerSubscription = null;
  //     }

  //     this.setState(() {
  //       //   this._isPlaying = false;
  //     });
  //   } catch (err) {
  //     print('error: $err');
  //   }
  // }

  // void pausePlayer() async {
  //   String result = await flutterSound.pausePlayer();
  //   print('pausePlayer: $result');
  // }

  // void resumePlayer() async {
  //   String result = await flutterSound.resumePlayer();
  //   print('resumePlayer: $result');
  // }

  // void seekToPlayer(int milliSecs) async {
  //   String result = await flutterSound.seekToPlayer(milliSecs);
  //   print('seekToPlayer: $result');
  // }

  // void addRecordEmLista() {
  //   //_recorderSubscription.
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          child: Column(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  if (!this._isRecording) {
                    return this._start();
                  }
                  this._stop();

                  //  this.startRecorder();
                  // addRecordEmLista();
                  //  startPlayer();
                },
                padding: EdgeInsets.all(8.0),
                child: this._isRecording
                    ? Icon(
                        Icons.stop,
                        size: 80,
                      )
                    : Icon(
                        Icons.mic,
                        size: 90,
                      ),
              ),
              Container(
                // margin: EdgeInsets.only(top: 60.0, bottom: 16.0),
                child: TimerText(stopwatch: stopwatch),
                //  Text(
                //   _recorderTxt.length > 10
                //       ? _recorderTxt.substring(2, 10)
                //       : _recorderTxt,
                //   style: TextStyle(
                //     fontSize: 18.0,
                //     color: Colors.black,
                //   ),
                // ),
              )
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.35,
          color: Colors.amber,
        ),
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.stopwatch});
  final Stopwatch stopwatch;

  TimerTextState createState() => new TimerTextState(stopwatch: stopwatch);
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  final Stopwatch stopwatch;

  TimerTextState({this.stopwatch}) {
    timer = new Timer.periodic(new Duration(milliseconds: 30), callback);
  }

  void callback(Timer timer) {
    if (stopwatch.isRunning) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle timerTextStyle =
        const TextStyle(fontSize: 20.0, fontFamily: "Open Sans");
    String formattedTime =
        TimerTextFormatter.format(stopwatch.elapsedMilliseconds);
    return new Text(formattedTime, style: timerTextStyle);
  }
}

class TimerTextFormatter {
  static String format(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr.$hundredsStr";
  }
}
// @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Sound'),
//         ),
//         body: ListView(
//           children: <Widget>[
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Container(
//                   margin: EdgeInsets.only(top: 24.0, bottom:16.0),
//                   child: Text(
//                     this._recorderTxt,
//                     style: TextStyle(
//                       fontSize: 48.0,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),
//                 _isRecording ? LinearProgressIndicator(
//                   value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//                   backgroundColor: Colors.red,
//                 ) : Container()
//               ],
//             ),
//             Row(
//               children: <Widget>[
//                 Container(
//                   width: 56.0,
//                   height: 56.0,

//                   child: ClipOval(
//                     child: FlatButton(
//                       onPressed: () {
//                         if (!this._isRecording) {
//                           return this.startRecorder();
//                         }
//                         this.stopRecorder();
//                       },
//                       padding: EdgeInsets.all(8.0),
//                       child: Image(
//                         image: this._isRecording ? AssetImage('res/icons/ic_stop.png') : AssetImage('res/icons/ic_mic.png'),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Container(
//                   margin: EdgeInsets.only(top: 60.0, bottom:16.0),
//                   child: Text(
//                     this._playerTxt,
//                     style: TextStyle(
//                       fontSize: 48.0,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: <Widget>[
//                 Container(
//                   width: 56.0,
//                   height: 56.0,
//                   child: ClipOval(
//                     child: FlatButton(
//                       onPressed: () {
//                         startPlayer();
//                       },
//                       padding: EdgeInsets.all(8.0),
//                       child: Image(
//                         image: AssetImage('res/icons/ic_play.png'),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 56.0,
//                   height: 56.0,
//                   child: ClipOval(
//                     child: FlatButton(
//                       onPressed: () {
//                         pausePlayer();
//                       },
//                       padding: EdgeInsets.all(8.0),
//                       child: Image(
//                         width: 36.0,
//                         height: 36.0,
//                         image: AssetImage('res/icons/ic_pause.png'),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 56.0,
//                   height: 56.0,
//                   child: ClipOval(
//                     child: FlatButton(
//                       onPressed: () {
//                         stopPlayer();
//                       },
//                       padding: EdgeInsets.all(8.0),
//                       child: Image(
//                         width: 28.0,
//                         height: 28.0,
//                         image: AssetImage('res/icons/ic_stop.png'),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//             ),
//             Container(
//               height: 56.0,
//               child: Slider(
//                 activeColor: Colors.amber,
//                 value: slider_current_position,
//                 min: 0.0,
//                 max: max_duration,
//                 onChanged: (double value) async{
//                   await flutterSound.seekToPlayer(value.toInt());
//                 },
//                 divisions: max_duration.toInt()
//               )
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
