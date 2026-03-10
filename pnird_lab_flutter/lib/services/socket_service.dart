import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class SocketService {
  IO.Socket? _socket;
  IO.Socket get socket => _socket!;
  bool get hasSocket => _socket != null;
  bool get isConnected => _socket?.connected == true;

  void connect(String userId) {
    _socket = IO.io(ApiService.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to Socket.IO server');
      _socket!.emit("register", userId);
    });

    _socket!.on("receive_message", (data) {
      print("Message received: ${data['message']}");
      // You can trigger UI updates here
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void sendMessage(String senderId, String recipientId, String message) {
    _socket?.emit("send_message", {
      "senderId": senderId,
      "recipientId": recipientId,
      "message": message,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
