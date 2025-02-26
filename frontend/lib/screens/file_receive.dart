import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:quick_drop/components/appbar.dart';

class FileReceivePage extends StatefulWidget {
  final String sessionKey;
  final SecretKey sharedSecret;

  const FileReceivePage({
    super.key,
    required this.sessionKey,
    required this.sharedSecret,
  });

  @override
  _FileReceivePageState createState() => _FileReceivePageState();
}

class _FileReceivePageState extends State<FileReceivePage> {
  late final String sessionKey;
  late final SecretKey sharedSecret;

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    sharedSecret = widget.sharedSecret;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('シグネチャ: ${sharedSecret.hashCode}'),
          ElevatedButton(
            onPressed: () async {
              // Implement file receive logic here
            },
            child: Text('ファイルを受信'),
          ),
        ],
      ))
    );
  }
}
