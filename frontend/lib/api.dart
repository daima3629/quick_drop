import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['API_URL'] ?? '${Uri.base.origin}/api';

Future<String> getSessionKey(EcPublicKey senderPubkey) async {
  final x = base64Encode(senderPubkey.x);
  final y = base64Encode(senderPubkey.y);
  final response = await http.post(
    Uri.parse('$apiUrl/session_key'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'pubkey_x': x, 'pubkey_y': y}),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['session_key'];
  } else {
    throw Exception('Failed to fetch session key: ${response.statusCode}');
  }
}

Future<EcPublicKey?> getReceiverPubkey(String sessionKey) async {
  final response = await http.get(
    Uri.parse('$apiUrl/receiver_pubkey?session_key=$sessionKey'),
  );

  if (response.statusCode == 204) {
    return null;
  } else if (response.statusCode == 200) {
    final data = json.decode(response.body);
    var x = base64Decode(data['pubkey_x']);
    var y = base64Decode(data['pubkey_y']);
    return EcPublicKey(x: x, y: y, type: KeyPairType.p521);
  } else {
    throw Exception('Failed to fetch receiver pubkey: ${response.statusCode}');
  }
}

Future<EcPublicKey> getSenderPubkey(String sessionKey, EcPublicKey receiverPubkey) async {
  final response = await http.post(
    Uri.parse('$apiUrl/sender_pubkey'),
    body: json.encode({
      'session_key': sessionKey,
      'pubkey_x': base64Encode(receiverPubkey.x),
      'pubkey_y': base64Encode(receiverPubkey.y),
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    var x = base64Decode(data['pubkey_x']);
    var y = base64Decode(data['pubkey_y']);
    return EcPublicKey(x: x, y: y, type: KeyPairType.p521);
  } else if (response.statusCode == 404) {
    throw Exception('Session key is not valid');
  } else {
    throw Exception('Failed to fetch sender pubkey: ${response.statusCode}');
  }
}
