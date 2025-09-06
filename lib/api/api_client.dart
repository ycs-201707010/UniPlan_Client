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

  // 음성 파일 관련 요청
  Future<dynamic> multiPost(
    String endpoint,
    String key, {
    required String filePath,
  }) async {
    final url = Uri.parse('$_url$endpoint');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath(key, filePath));

    final streamedResponse = await request.send();

    //StreamedResponse를 일반 http.Response로 변환
    final response = await http.Response.fromStream(streamedResponse);

    // 6. post 함수와 동일한 방식으로 응답을 처리하여 반환
    return _handleResponse(response);
  }
}
