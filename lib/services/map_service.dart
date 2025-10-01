  // // 에브리타임 시간표 링크를 통해 정보를 크롤링하여 가져오는 메서드
  // Future<void> getTrangit(
  //   String origin,
  //   String destination,
  //   TimeOfDay? departureTime,
  // ) async {
  //   final Map<String, dynamic> body = {
  //     "origin": origin,
  //     "destination": destination,
  //     if (departureTime != null) "departure_time": departureTime,
  //   };

  //   try {
  //     final response = await _apiClient.post('/map/getTrangit', body: body);
  //     var json = jsonDecode(response.body);
  //     var message = json['message'];

  //     // 입력받은 기간에 존재하는 요일 갯수 만큼 생성하고 currentTimetable에 추가
  //     if (message == "Get Transit Successed") {
  //     } else {
  //       throw Exception('Get Transit Failed: $message');
  //     }
  //   } catch (e) {
  //     print('이동 거리를 계산하는 과정에서 에러 발생: $e');
  //     // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
  //     rethrow;
  //   }
  // }

  // // 에브리타임 시간표 링크를 통해 정보를 크롤링하여 가져오는 메서드
  // Future<void> saveTrangit(
  //   int userId,
  //   int placeId1,
  //   int placeId2,
  //   TimeOfDay? departureTime,
  // ) async {
  //   final Map<String, dynamic> body = {
  //     "user_id": userId,
  //     "place1_id": placeId1,
  //     "place2_id": placeId2,
  //     if (departureTime != null) "departure_time": departureTime,
  //   };

  //   try {
  //     final response = await _apiClient.post('/map/saveTrangit', body: body);
  //     var json = jsonDecode(response.body);
  //     var message = json['message'];

  //     // 입력받은 기간에 존재하는 요일 갯수 만큼 생성하고 currentTimetable에 추가
  //     if (message == "Save Transit Successed") {
  //     } else {
  //       throw Exception('Save Transit Failed: $message');
  //     }
  //   } catch (e) {
  //     print('이동 거리를 저장하는 과정에서 에러 발생: $e');
  //     // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
  //     rethrow;
  //   }
  // }