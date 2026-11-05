import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../app/config/config.dart';
import '../storage/secure_storage_service.dart';

class WebSocketClient {
  WebSocketChannel? _channel;
  final SecureStorageService _storage = SecureStorageService();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return;

      final uri = Uri.parse('${AppConfig.defaultWsBaseUrl}?token=$token');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          try {
            final parsed = jsonDecode(data.toString()) as Map<String, dynamic>;
            _messageController.add(parsed);
          } catch (_) {}
        },
        onError: (_) {},
        onDone: () {},
      );
    } catch (_) {}
  }

  void subscribeSos(String sosId) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'SubscribeSos',
        'payload': {'sos_id': sosId},
      }));
    }
  }

  void updateLocation({
    required String sosId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'UpdateLocation',
        'payload': {
          'sos_id': sosId,
          'latitude': latitude,
          'longitude': longitude,
          'heading': heading,
          'speed_kmh': speedKmh,
        },
      }));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}

