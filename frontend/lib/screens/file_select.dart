import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:quick_drop/components/appbar.dart';

class FileSelectPage extends StatefulWidget {
  final String sessionKey;
  final SecretKey sharedSecret;

  const FileSelectPage({
    super.key,
    required this.sessionKey,
    required this.sharedSecret,
  });

  @override
  _FileSelectPageState createState() => _FileSelectPageState();
}

class _FileSelectPageState extends State<FileSelectPage> {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('シグネチャ: ${sharedSecret.hashCode}'),
            ElevatedButton(
              onPressed: () async {
                // Implement file picker logic here
              },
              child: Text('ファイルを選択'),
            ),
          ],
        ),
      ),
    );
  }
}
