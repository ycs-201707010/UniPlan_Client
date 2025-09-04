import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/models/user_model.dart';
import 'package:all_new_uniplan/api/api_client.dart';

class AuthService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // _를 통해 외부에서 접근할 수 없도록 지정 (원본 데이터)
  User? _currentUser;

  // 외부에서 currentUser에 접근했을 때 _currentUser의 주소 값을 가짐
  // but 읽기만 가능 (getter 역할)
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> login(String id, String password) async {
    final Map<String, dynamic> body = {"username": id, "password": password};

    try {
      final response = await _apiClient.post('/login', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Login Successed") {
        var userJson = json['user'];
        print(userJson);
        User user = User.fromJson(userJson);
        _currentUser = user;

        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else {
        throw Exception('Login Failed: $message');
      }
    } catch (e) {
      print('로그인 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 회원가입 과정을 처리하는 메서드.
  Future<void> register(
    String username,
    String password, {
    String? nickname,
    int? age,
    String? gender,
    DateTime? birthday,
    String? email,
  }) async {
    final Map<String, dynamic> body = {
      'username': username,
      'password': password,
      if (nickname != null) 'nickname': nickname,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': birthday.toIso8601String(),
      if (email != null) 'email': email,
    };

    try {
      final response = await _apiClient.post('/login/register', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Register Successed") {
        int userId = json['user_id'] as int;
        DateTime joinDate = DateTime.parse(json['join_date']);

        _currentUser = User(
          userId: userId,
          username: username,
          nickname: nickname,
          age: age,
          gender: gender,
          birthday: birthday,
          email: email,
          joinDate: joinDate,
        );
        // 만약 회원가입 시 바로 로그인 페이지로 이동하는 경우
        // login(id, password);
      } else {
        throw Exception('Sign up Failed: $message');
      }
    } catch (e) {
      print('로그인 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 로그아웃 시 호출되는 메서드
  void logout() {
    _currentUser = null;
    notifyListeners(); // 상태 변경을 구독자들에게 알림
  }
}
