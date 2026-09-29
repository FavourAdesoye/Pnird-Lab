import 'package:firebase_auth/firebase_auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class SocketService {
  IO.Socket? _socket;
  IO.Socket get socket => _socket!;
  bool get hasSocket => _socket != null;
  bool get isConnected => _socket?.connected == true;

  /// Connect with Firebase ID token. Server ignores client-supplied userId.
  /// Returns false if there is no token or the socket could not be created.
  Future<bool> connect(String userId) async {
    String? token;
    try {
      token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    } catch (_) {
      token = null;
    }

    // Avoid connecting without auth — server will reject and chats fail silently.
    if (token == null || token.isEmpty) {
      print('Socket connect skipped: no Firebase token');
      disconnect();
      return false;
    }

    _socket?.dispose();
    _socket = IO.io(
      ApiService.socketUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'forceNew': true,
      },
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to Socket.IO server');
      // Compatibility emit; server binds to authenticated Mongo user
      _socket!.emit('register', userId);
    });

    _socket!.onConnectError((err) {
      print('Socket connect error: $err');
    });

    _socket!.on('receive_message', (data) {
      print('Message received: ${data['message']}');
    });

    _socket!.on('error', (data) {
      print('Socket error: $data');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from server');
    });

    return true;
  }

  void sendMessage(String senderId, String recipientId, String message) {
    // senderId is ignored by the server (uses authenticated user)
    _socket?.emit('send_message', {
      'recipientId': recipientId,
      'message': message,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
