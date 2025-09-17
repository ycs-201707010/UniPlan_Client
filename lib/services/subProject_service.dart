// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:all_new_uniplan/api/api_client.dart';
// import 'package:all_new_uniplan/models/project_model.dart';
// import 'package:all_new_uniplan/models/subProject_model.dart';

// class SubProjectService with ChangeNotifier {
//   final ApiClient _apiClient = ApiClient();

//   // 메서드가 실행되고 있음을 나타내는 필드
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<List<SubProject>> getSubProject(int projectId) async {
//     final Map<String, dynamic> body = {"project_id": projectId};

//     try {
//       final response = await _apiClient.post(
//         '/project/getSubProject',
//         body: body,
//       );
//       var json = jsonDecode(response.body);
//       var message = json['message'];

//       if (message == "Get SubProject Successed") {
//         var subProjectList = json["subproject"] as List;
//         // JSON 리스트를 SubProject 객체 리스트로 변환하여 반환

//         return subProjectList.map((item) => SubProject.fromJson(item)).toList();
//       } else {
//         throw Exception('Get SubProject Failed: $message');
//       }
//     } catch (e) {
//       print('서브 프로젝트를 검색하는 과정에서 에러 발생: $e');
//       // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
//       rethrow;
//     }
//   }

//   Future<SubProject> addSubProject(int projectId, SubProject subProject) async {
//     try {
//       final response = await _apiClient.post(
//         '/project/addSubProject',
//         body: body,
//       );
//       var json = jsonDecode(response.body);
//       var message = json['message'];

//       if (message == "Add SubProject Successed") {
//         var subProjectJson = json["subproject"];
//         final newSubProject = SubProject.fromJson(subProjectJson);

//         return newSubProject;
//       } else {
//         throw Exception('Add SubProject Failed: $message');
//       }
//     } catch (e) {
//       print('서브 프로젝트를 추가하는 과정에서 에러 발생: $e');
//       // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
//       rethrow;
//     }
//   }

//   Future<SubProject> addMultipleSubProject(Map<String, dynamic> body) async {
//     try {
//       final response = await _apiClient.post(
//         '/project/addSubProject',
//         body: body,
//       );
//       var json = jsonDecode(response.body);
//       var message = json['message'];

//       if (message == "Add SubProject Successed") {
//         var subProjectJson = json["subproject"];
//         final newSubProject = SubProject.fromJson(subProjectJson);

//         return newSubProject;
//       } else {
//         throw Exception('Add SubProject Failed: $message');
//       }
//     } catch (e) {
//       print('서브 프로젝트를 추가하는 과정에서 에러 발생: $e');
//       // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
//       rethrow;
//     }
//   }
// }
