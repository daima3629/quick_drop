import 'dart:async';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_drop/api.dart';
import 'package:quick_drop/components/appbar.dart';
import 'package:quick_drop/screens/file_receive.dart';
import 'package:quick_drop/screens/file_select.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late Future future;
  late EcKeyPair keyPair;
  late String? sessionKey;
  late QrImageView qrCodeImage;
  late Timer? _timer;


  Future<void> _initialize() async {
    print(Uri.base.queryParameters);
    if (Uri.base.queryParameters.containsKey('session_key')) {
      // 受信者
      sessionKey = Uri.base.queryParameters['session_key'];
      var algo = Ecdh.p521(length: 521);
      keyPair = await algo.newKeyPair();
      var pubkey = await keyPair.extractPublicKey();
      var senderPubkey = await getSenderPubkey(sessionKey!, pubkey);
      var sharedSecret = await algo.sharedSecretKey(
        keyPair: keyPair,
        remotePublicKey: senderPubkey,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => FileReceivePage(
                sessionKey: sessionKey!,
                sharedSecret: sharedSecret,
              ),
        ),
      );
    } else {
      // 送信者
      var algo = Ecdh.p521(length: 521);
      keyPair = await algo.newKeyPair();
      var pubkey = await keyPair.extractPublicKey();
      sessionKey = await getSessionKey(pubkey);
      print('${Uri.base.origin}/app?session_key=$sessionKey');
      qrCodeImage = QrImageView(
        data: '${Uri.base.origin}/app?session_key=$sessionKey',
        version: QrVersions.auto,
        size: 200.0,
      );
      _startReceiverPubkeyPolling();
    }
  }

  void _startReceiverPubkeyPolling() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      var receiverPubkey = await getReceiverPubkey(sessionKey!);
      if (receiverPubkey != null) {
        _timer?.cancel();
        var algo = Ecdh.p521(length: 521);
        var sharedSecret = await algo.sharedSecretKey(
          keyPair: keyPair,
          remotePublicKey: receiverPubkey,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => FileSelectPage(
                  sessionKey: sessionKey!,
                  sharedSecret: sharedSecret,
                ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text('Quick Drop'),
            ),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), Text('Loading...')],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Scaffold(
          appBar: CommonAppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [qrCodeImage, Text('相手にQRコードを読み取らせて開始')],
            ),
          ),
        );
      },
    );
  }
}
