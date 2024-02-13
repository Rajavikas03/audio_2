// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:io';
// import 'package:android_path_provider/android_path_provider.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_sound/flutter_sound.dart';

typedef _Fn = void Function();

//const theSource = AudioSource.voiceUpLink;
//const theSource = AudioSource.voiceDownlink;

const theSource = AudioSource.microphone;

/// Example app.
class SimpleRecorder extends StatefulWidget {
  const SimpleRecorder({super.key});

  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  Codec _codec = Codec.aacMP4;
  String _mPath = 'tau_file.mp4';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String twoDigitMinutes = " ";
  String twoDigitSeconds = " ";
  String musicPath = "";
  // String song =
  //     "/Users/rajavikas/My_space/flutter projects/innowave24_audio_apk/assets/song.mp3";

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  // void getAndroidPaths() async {
  //   // var alarmsPath = await AndroidPathProvider.alarmsPath;
  //   // var dcimPath = await AndroidPathProvider.dcimPath;
  //   // var documentsPath = await AndroidPathProvider.documentsPath;
  //   // var downloadsPath = await AndroidPathProvider.downloadsPath;
  //   // var moviesPath = await AndroidPathProvider.moviesPath;
  //   musicPath = await AndroidPathProvider.musicPath;
  //   // var notificationsPath = await AndroidPathProvider.notificationsPath;
  //   // var picturesPath = await AndroidPathProvider.picturesPath;
  //   // var podcastsPath = await AndroidPathProvider.podcastsPath;
  //   // var ringtonesPath = await AndroidPathProvider.ringtonesPath;
  // }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }

    // final file = await getTemporaryDirectory();
    await _mRecorder!.openRecorder();
    _mRecorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      // Directory file = await getApplicationDocumentsDirectory();
      // try {
      _mPath = 'tau_file.webm';
      // } catch (e) {
      //   print(e);
      // }
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  // <----------------------  Here is the code for recording and playback --------------------->

// Start recording
  void record() {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {});
    });
  }

// Stop recording
  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
  }

// Play Audio
  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

// Stop playing
  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

// Record function
  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

// Play function
  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

// <----------------------------- UI -------------------------------------------->
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RecordingDisposition>(
            builder: (context, snapshot) {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;

              String twoDigits(int n) => n.toString().padLeft(2, '0');

              twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
              twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

              return Text(
                '$twoDigitMinutes:$twoDigitSeconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
            stream: _mRecorder!.onProgress,
          ),
          const Gap(30),
          Center(
            child: ElevatedButton(
                onPressed: getRecorderFn(),
                child: SizedBox(
                    width: width * 0.25,
                    height: height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(_mRecorder!.isRecording ? Icons.stop : Icons.mic),
                        Expanded(
                            child: Text(_mRecorder!.isRecording
                                ? 'Stop...'
                                : "Recording."))
                      ],
                    ))),
          ),
          const Gap(40),
          Center(
            child: ElevatedButton(
              onPressed: getPlaybackFn(),
              child: SizedBox(
                // color: Colors.cyan,
                width: width * 0.25,
                height: height * 0.06,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      _mPlayer!.isPlaying ? Icons.stop : Icons.play_arrow,
                      color: _mPlayer!.isPlaying ? Colors.red : null,
                    ),
                    Text(
                      _mPlayer!.isPlaying ? 'Stop' : 'Play',
                      // style: const TextStyle(color: Colors.cyan),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
