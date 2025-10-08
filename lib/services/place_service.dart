import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/place_model.dart';

class PlaceService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // _를 통해 외부에서 접근할 수 없도록 지정 (원본 데이터)
  final List<Place> _placeList = [];
  List<Place> get placeList => _placeList;

  Future<void> getPlaces(int userId) async {
    final Map<String, dynamic> body = {"user_id": userId};

    try {
      final response = await _apiClient.post('/place/getPlaces', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      // 입력받은 기간에 존재하는 요일 갯수 만큼 생성하고 currentTimetable에 추가
      if (message == "Get Places Successed") {
        _placeList.clear();
        var result = json['result'];
        var placeJsonList = result as List<dynamic>;

        Place home = Place(placeId: -1, name: "집", address: "");
        _placeList.add(home);

        for (final placeJson in placeJsonList) {
          Place place = Place.fromJson(placeJson as Map<String, dynamic>);
          if (place.name == "집") {
            _placeList.first = place;
            continue;
          }

          _placeList.add(place);
        }
        notifyListeners();
      } else {
        throw Exception('Get Places Failed: $message');
      }
    } catch (e) {
      print('장소를 저장하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  Future<void> addPlace(int userId, String? name, String? address) async {
    final Map<String, dynamic> body = {
      "user_id": userId,
      "name": name,
      "address": address,
    };

    try {
      final response = await _apiClient.post('/place/addPlace', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      // 입력받은 기간에 존재하는 요일 갯수 만큼 생성하고 currentTimetable에 추가
      if (message == "Add Place Successed") {
        int placeId = json['place_id'] as int;
        final place = Place(placeId: placeId, name: name!, address: address!);
        addPlaceToList(place);
      } else {
        throw Exception('Add Place Failed: $message');
      }
    } catch (e) {
      print('장소를 저장하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  Future<void> deletePlace(int userId, String name) async {
    final Map<String, dynamic> body = {"user_id": userId, "name": name};

    try {
      final response = await _apiClient.post('/place/deletePlace', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      // 입력받은 기간에 존재하는 요일 갯수 만큼 생성하고 currentTimetable에 추가
      if (message == "Delete Place Successed") {
        deletePlaceFromList(name);
      } else {
        throw Exception('Delete Place Failed: $message');
      }
    } catch (e) {
      print('장소를 삭제하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  Future<void> modifyPlace(
    int userId,
    String name,
    String newName,
    String newAddress,
  ) async {
    final Map<String, dynamic> body = {
      "user_id": userId,
      "name": name,
      "new_name": newName,
      "new_address": newAddress,
    };

    try {
      final response = await _apiClient.post('/place/modifyPlace', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      // 입력받은 기간에 존재하는 요일 갯수 만큼 생성하고 currentTimetable에 추가
      if (message == "Modify Place Successed") {
        updatePlaceFromList(name, newName, newAddress);
      } else {
        throw Exception('Modify Place Failed: $message');
      }
    } catch (e) {
      print('장소를 수정하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  void addPlaceToList(Place place) {
    _placeList.add(place);
  }

  void deletePlaceFromList(String name) {
    _placeList.removeWhere((place) => place.name == name);
  }

  void updatePlaceFromList(String name, String newName, String newAddress) {
    final index = _placeList.indexWhere((place) => place.name == name);

    // 인덱스를 찾았다면 (-1이 아니라면) 해당 요소의 필드를 수정합니다.
    if (index != -1) {
      _placeList[index].name = newName;
      _placeList[index].address = newAddress;
    }
  }
}
