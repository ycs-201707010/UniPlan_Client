import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/utils/formatters.dart';

@immutable
class Place {
  int? placeId;
  String name;
  String address;
  DateTime? timestamp;

  Place({
    this.placeId,
    required this.name,
    required this.address,
    this.timestamp,
  });

  Place copyWith({
    int? placeId,
    String? name,
    String? address,
    DateTime? timestamp,
  }) {
    return Place(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      if (placeId != null) 'place_id': placeId,
      'name': name,
      'address': address,
    };

    return jsonMap;
  }

  // JSON 데이터를 받아 Project 객체를 생성하는 factory 생성자
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      timestamp:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );
  }
}
