import 'package:flutter/material.dart';

// const 생성자를 사용하기 위해 @immutable 추가 (클래스 내의 필드 수정 불가)
@immutable
class User {
  final int userId;
  final String username;
  final String? nickname;
  final int? age;
  final String? gender;
  final DateTime? birthday;
  final String? email;
  final DateTime? joinDate;

  const User({
    required this.userId,
    required this.username,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.birthday,
    required this.email,
    required this.joinDate,
  });

  // 필드 수정시  새 객체를 생성하는 메서드
  User copyWith({
    int? userId,
    String? username,
    String? nickname,
    int? age,
    String? gender,
    DateTime? birthday,
    String? email,
    DateTime? joinDate,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  // json 값을 변환하여 자기 자신의 필드를 초기화하고 자신을 반환하는 메서드
  factory User.fromJson(dynamic json) {
    return User(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      email: json['email'] as String?,

      // DateTime? 타입은 null 체크 후 파싱
      birthday:
          json['birthday'] != null
              ? DateTime.parse(json['birthday'] as String)
              : null,
      joinDate:
          json['join_date'] != null
              ? DateTime.parse(json['join_date'] as String)
              : null,
    );
  }

  // toJson 메서드에 누락된 필드 추가
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      if (nickname != null) 'nickname': nickname,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': birthday?.toIso8601String(),
      if (email != null) 'email': email,
      if (joinDate != null) 'join_date': joinDate?.toIso8601String(),
    };
  }
}
