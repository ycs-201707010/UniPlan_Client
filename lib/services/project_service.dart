import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/project_model.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';
import 'package:all_new_uniplan/services/subProject_service.dart';

class ProjectService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Map<int, Project>? _projects = {};
  Map<int, Project>? get projects => _projects;

  // 메서드가 실행되고 있음을 나타내는 필드
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final SubProjectService _subProjectService = SubProjectService();

  // DB에 입력한 장기 프로젝트 정보를 추가하고 projectId를 반환받아
  // _projects 필드에 추가하는 메서드
  Future<void> addProject(
    int userId,
    String title,
    String goal,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'title': title,
      'goal': goal,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    try {
      final response = await _apiClient.post('/project/addProject', body: body);

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Add Project Successed") {
        var projectId = json['project_id'] as int;
        Project project = Project(
          projectId: projectId,
          title: title,
          goal: goal,
          startDate: startDate,
          endDate: endDate,
        );
        addProjectToMap(project);
        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
      } else {
        throw Exception('Add Project Failed: $message');
      }
    } catch (e) {
      print('프로젝트를 추가하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // Future<void> addProjectAndSubProject(
  //   int userId,
  //   String title,
  //   String goal,
  //   DateTime startDate,
  //   DateTime endDate,
  // ) async {
  //   final Map<String, dynamic> body = {
  //     'user_id': userId,
  //     'title': title,
  //     'goal': goal,
  //     'start_date': startDate,
  //     'end_time': endDate,
  //   };

  //   try {
  //     final response = await _apiClient.post('/project/addProject', body: body);

  //     var json = jsonDecode(response.body);
  //     var message = json['message'];

  //     if (message == "Add Project Successed") {
  //       // _project = Project.fromJson(json['project'] as Map<String, dynamic>);

  //       // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
  //       notifyListeners();
  //     } else {
  //       throw Exception('Add Project Failed: $message');
  //     }
  //   } catch (e) {
  //     print('프로젝트를 추가하는 과정에서 에러 발생: $e');
  //     // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
  //     rethrow;
  //   }
  // }

  // projectId를 가진 장기 프로젝트를 검색하여 Project를 초기화하여
  // 이를 저장하는 Map 타입 필드에 추가하고
  // 해당 장기 프로젝트의 서브 프로젝트 정보를 초기화하는 메서드
  Future<void> getProjectByProjectId(int projectId) async {
    final Map<String, dynamic> body = {"project_id": projectId};

    try {
      final response = await _apiClient.post(
        '/project/getProjectByProjectId',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Get Project Successed") {
        var projectJson = json["project"];
        Project project = Project.fromJson(projectJson as Map<String, dynamic>);
        addProjectToMap(project);
        getSubProject(projectId);
        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else {
        throw Exception('Get Project Failed: $message');
      }
    } catch (e) {
      print('프로젝트를 검색하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // UserId를 통해 해당 User가 생성한 장기 프로젝트와 서브 프로젝트를
  // 모두 검색하여 초기화하는 메서드
  Future<void> getProjectByUserId(int userId) async {
    final Map<String, dynamic> body = {"user_id": userId};

    try {
      final response = await _apiClient.post(
        '/project/getProjectByUserId',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get Project Successed") {
        var projectsJson = json["projects"];
        updateProjectMapFromJson(projectsJson);
        if (_projects!.length != 0) {
          _projects!.forEach((key, value) {
            getSubProject(key);
          });
        }
        notifyListeners();
      } else {
        throw Exception('Get Project Failed: $message');
      }
    } catch (e) {
      print('프로젝트를 검색하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 장기 프로젝트의 서브 프로젝트를 DB에 추가하고 subProjectId를 반환받아
  // 해당 장기 프로젝트의 _subProjects 필드에 추가하는 메서드
  Future<void> addSubProject(
    int projectId,
    String subGoal, {
    int? done,
    int? maxDone,
    int? cycle,
    DateTime? date,
    String? projectType,
  }) async {
    final Map<String, dynamic> body = {
      'project_id': projectId,
      'subgoal': subGoal,
      if (done != null) 'done': done,
      if (maxDone != null) 'max_done': maxDone,
      if (cycle != null) 'cycle': cycle,
      if (date != null) 'date': date.toIso8601String(),
      if (projectType != null) 'project_type': projectType,
    };

    try {
      final response = await _apiClient.post(
        '/project/addSubProject',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Add SubProject Successed") {
        var subProjectId = json['subproject_id'] as int;
        SubProject subProject = new SubProject(
          subProjectId: subProjectId,
          subGoal: subGoal,
          done: done,
          maxDone: maxDone,
          cycle: cycle,
          date: date,
          projectType: projectType,
        );
        addSubProjectToList(projectId, subProject);
      } else {
        throw Exception('Add SubProject Failed: $message');
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 장기 프로젝트 하위 프로젝트를 검색하여 초기화하는 메서드
  Future<void> getSubProject(int projectId) async {
    final Map<String, dynamic> body = {'project_id': projectId};
    try {
      final response = await _apiClient.post(
        '/project/getSubProject',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Get SubProject Successed") {
        var subProjectsJson = json['subprojects'];
        updateSubProjectListFromJson(projectId, subProjectsJson);
      } else {
        throw Exception('Get SubProject Failed: $message');
      }
    } catch (e) {
      // 에러 처리
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 장기 프로젝트를 이를 저장하는 Map타입의 필드에 추가하는 메서드
  void addProjectToMap(Project project) {
    _projects![project.projectId] = project;
    notifyListeners();
  }

  // json에 지정된 여러 개의 Project 정보들을 추출하여 이를 저장하는 Map 타입 필드에 저장하는 메서드
  void updateProjectMapFromJson(dynamic projectsJson) {
    // 기존 목록을 비움
    _projects!.clear();
    final projectMap = projectsJson as Map;
    // 맵을 반복하며 모델의 fromJson 생성자를 사용
    projectMap.forEach((key, value) {
      final project = Project.fromJson(value as Map<String, dynamic>);
      projects![project.projectId] = project;
    });

    // UI에 변경사항 알림
    notifyListeners();
  }

  // json에 지정된 여러 개의 SubProject 정보들을 추출하여 이를 저장하는 List 타입 필드에 저장하는 메서드
  void updateSubProjectListFromJson(int projectId, dynamic subProjectsJson) {
    // 기존 목록을 비움
    _projects![projectId]!.subProjects!.clear();
    final subProjectMap = subProjectsJson as Map;
    // 맵을 반복하며 모델의 fromJson 생성자를 사용
    subProjectMap.forEach((key, value) {
      final subProject = SubProject.fromJson(value as Map<String, dynamic>);
      projects![projectId]!.subProjects!.add(subProject);
    });

    // UI에 변경사항 알림
    notifyListeners();
  }

  // 서브 프로젝트를 해당 장기 프로젝트의 이를 저장하는 List 타입 필드에 추가하는 메서드
  void addSubProjectToList(int projectId, SubProject subProject) {
    _projects![projectId]!.subProjects!.add(subProject);
    notifyListeners();
  }
}
