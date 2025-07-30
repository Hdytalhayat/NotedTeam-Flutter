// lib/api/websocket_service.dart
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<String> _streamController = StreamController<String>.broadcast();

  // Stream untuk didengarkan oleh provider
  Stream<String> get messages => _streamController.stream;

  void connect(int teamId, String token) {
    // Pastikan koneksi sebelumnya ditutup
    disconnect(); 
    
    // Ganti http dengan ws
    final url = 'ws://192.168.1.3:8080/api/ws/teams/$teamId?token=$token';
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen((message) {
        // Teruskan pesan yang masuk ke stream controller kita
        _streamController.add(message);
      }, onDone: () {
        // Handle saat koneksi ditutup oleh server
        print("WebSocket channel closed");
      }, onError: (error) {
        // Handle error koneksi
        print("WebSocket error: $error");
      });
    } catch (e) {
      print("Error connecting to WebSocket: $e");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}