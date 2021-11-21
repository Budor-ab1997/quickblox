import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:quickblox_sdk/models/qb_attachment.dart';
import 'package:quickblox_sdk/models/qb_dialog.dart';
import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';
import 'package:quickblox_sdk/webrtc/rtc_video_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appId = "94597";
  String authKey = "9gBUw9Czzj9WdAE";
  String authSecret = "tSfyAV5CBpzrfzG";
  String accountKey = "YtuhUrdzb3CjLB7sJz_6";

  String USER_LOGIN = "Budor";
  String USER_PASSWORD = "12121212";
  int USER_ID = 131957427;
  String? _dialogId;
  List<int> OPPONENTS_IDS = [22345, 23521];
  bool _videoCall = true;

  //int sessionType = QBRTCSessionTypes.VIDEO;
  String? _sessionId;

  StreamSubscription? _callSubscription;
  RTCVideoViewController? _localVideoViewController;

  int userId = 7832;

  @override
  void dispose() {
    super.dispose();
    if (_callSubscription != null) {
      _callSubscription!.cancel();
      _callSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TEST'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
                padding: EdgeInsets.only(top: 16),
                child: MaterialButton(
                    minWidth: 200,
                    child: const Text('Login'),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () async {
                      try {
                        QB.settings
                            .init(appId, authKey, authSecret, accountKey);

                        login();
                      } catch (e) {
                        print(e);
                      }
                    })),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('Connect to the chat '),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () {
                    connect();
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('Get Session'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    await getSession();
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('Create Dialog'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    createDialog();
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text(
                      'Join Dialog to start send and recieve message'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    joinDialog();
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('Send text message'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    sendMessage();
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('Initialize WebRTC'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    init();
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('Realease WebRTC'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    releaseWebRTC();
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('call WebRTC'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    callWebRTC(QBRTCSessionTypes.VIDEO);
                    setState(() {
                      _videoCall = true;
                    });
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('Accept WebRTC'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    acceptWebRTC(_sessionId!);
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: MaterialButton(
                  minWidth: 200,
                  child: const Text('play'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    play();
                  }),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              width: 160.0,
              height: 160.0,
              child: RTCVideoView(
                onVideoViewCreated: _onLocalVideoViewCreated,
              ),
              decoration: BoxDecoration(color: Colors.black54),
            )
          ]),
        ),
      ),
    );
  }

  //login to the quickblox
  Future<void> login() async {
    try {
      QBLoginResult result = await QB.auth.login(USER_LOGIN, USER_PASSWORD);
      QBUser? qbUser = result.qbUser;
      QBSession? qbSession = result.qbSession;
    } catch (e) {
      print(e);
    }
  }

  //connect to chat

  void connect() async {
    try {
      await QB.chat.connect(USER_ID, USER_PASSWORD);
      print("chat connected successfully");
    } on PlatformException catch (e) {
      print(e);
    }
  }

  // to check if there is session or not ..
  Future<void> getSession() async {
    try {
      QBSession? session = await QB.auth.getSession();
      if (session != null) {
        print("Get session success");
      } else {
        print("The session is null");
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void createDialog() async {
    List<int> occupantIds = [123456789, 234567891];
    String dialogName = "Group Chat";
    String dialogPhoto = "some photo url";

    int dialogType = QBChatDialogTypes.GROUP_CHAT;

    try {
      QBDialog? createdDialog = await QB.chat.createDialog(
          occupantIds, dialogName,
          dialogType: dialogType, dialogPhoto: dialogPhoto);

      if (createdDialog != null) {
        _dialogId = createdDialog.id!;

        print("The dialog $_dialogId was created");
      }
    } catch (e) {
      print(e);
    }
  }

  void joinDialog() async {
    try {
      String dialogId = "61963a05b52ce70031bd5133";
      await QB.chat.joinDialog(dialogId);
      print("joined successfully");
    } catch (e) {
      print(e);
    }
  }

  void sendMessage() async {
    String dialogId = "619a043baf1e27002ff1d0cd";
    String body = "test body Budor";
    List<QBAttachment>? attachments = [];
    Map<String, String>? properties = Map();
    bool markable = false;
    // String dateSent = "2000-023T01:23:45.678+09:00";
    bool saveToHistory = true;

    try {
      await QB.chat.sendMessage(dialogId,
          body: body,
          attachments: attachments,
          properties: properties,
          markable: markable,
          //dateSent: dateSent,
          saveToHistory: saveToHistory);
      print('sent successfully');
    } on PlatformException catch (e) {
      // Some error occurred, look at the exception message for more details
    }
  }

  //Initialize WebRTC
  Future<void> init() async {
    try {
      await QB.webrtc.init();
      print("WebRTC was initiated");
    } catch (e) {
      print(e);
    }
  }

  Future<void> releaseWebRTC() async {
    try {
      await QB.webrtc.release();
      print("WebRTC was released");
      _sessionId = null;
    } catch (e) {
      print(e);
    }
  }

  Future<void> callWebRTC(int sessionType) async {
    try {
      QBRTCSession? session = await QB.webrtc.call(OPPONENTS_IDS, sessionType);
      _sessionId = session!.id;
      print("The call was initiated for session id: $_sessionId");
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> acceptWebRTC(String sessionId) async {
    try {
      QBRTCSession? session = await QB.webrtc.accept(sessionId);
      String? receivedSessionId = session!.id;
      print("Session with id: $receivedSessionId was accepted");
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void _onLocalVideoViewCreated(RTCVideoViewController controller) {
    _localVideoViewController = controller;
  }

  Future<void> play() async {
    _localVideoViewController!.play(
      _sessionId!,
      userId,
    );
    print("play successfully");
  }
}