import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _domain = 'capstoneserver.ddns.net';
  static const String _url = "https://$_domain"; // static 변수끼리는 참조 가능

  // 공통 헤더
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    // 'Authorization': 'Bearer YOUR_TOKEN', // 인증 토큰이 필요하다면 여기에 추가
  };

  // GET 요청
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$_url$endpoint');
    final response = await http.get(url, headers: _headers);
    return _handleResponse(response);
  }

  // POST 요청
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$_url$endpoint');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // 응답 처리
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // UTF-8로 디코딩하여 한글 깨짐 방지
      return response;
    } else {
      // 에러 발생 시 예외 처리
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
