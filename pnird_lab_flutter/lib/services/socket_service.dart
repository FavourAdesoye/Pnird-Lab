import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class SocketService {
  late IO.Socket socket;

  void connect(String userId) {
    socket = IO.io(ApiService.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
      socket.emit("register", userId);
    });

    socket.on("receive_message", (data) {
      print("Message received: ${data['message']}");
      // You can trigger UI updates here
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void sendMessage(String senderId, String recipientId, String message) {
    socket.emit("send_message", {
      "senderId": senderId,
      "recipientId": recipientId,
      "message": message,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
