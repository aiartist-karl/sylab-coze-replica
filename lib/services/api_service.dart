import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://47.116.29.140:8000';
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'username': username,
        'password': password,
      });
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? response.data : jsonDecode(response.data);
        final token = data['access_token'] ?? data['token'];
        if (token != null) await saveToken(token.toString());
        return Map<String, dynamic>.from(data);
      }
      return {'error': 'Login failed', 'status': response.statusCode};
    } on DioException catch (e) {
      return {'error': e.message ?? 'Network error'};
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async => await clearToken();

  Stream<String> chatStream(String message, {String? botId}) async* {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {'message': message, if (botId != null) 'bot_id': botId},
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      if (response.data is ResponseBody) {
        final body = response.data as ResponseBody;
        final chunks = <int>[];
        await for (final chunk in body.stream) {
          chunks.addAll(chunk);
        }
        final decoded = utf8.decode(chunks);
        for (final line in const LineSplitter().convert(decoded)) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') return;
            try {
              final json = jsonDecode(data);
              final content = json['content'] ?? json['text'] ?? json['delta'] ?? '';
              if (content.toString().isNotEmpty) yield content.toString();
            } catch (_) {
              if (data.isNotEmpty) yield data;
            }
          } else if (line.isNotEmpty && !line.startsWith(':')) {
            yield line;
          }
        }
      } else if (response.data is String) {
        yield response.data.toString();
      }
    } on DioException catch (e) {
      yield '[Error: ${e.message ?? 'Network error'}]';
    } catch (e) {
      yield '[Error: $e]';
    }
  }

  Future<List<Map<String, dynamic>>> getBots() async {
    try {
      final r = await _dio.get('/api/bots');
      if (r.data is List) return (r.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      return [];
    } on DioException { return []; }
  }
}
