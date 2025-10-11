import 'dart:convert';
import 'package:all_new_uniplan/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/project_model.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';

class ProjectService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // projectId, Project 쌍
  final Map<int, Project> _projects = {};
  Map<int, Project>? get projects => _projects;

  // 메서드가 실행되고 있음을 나타내는 필드
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // final SubProjectService _subProjectService = SubProjectService();

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

  // LLM 프로젝트 추가 응답에 대해 사용자가 추가를 요청한 경우
  // 프로젝트와 하위 프로젝트를 추가하는 메서드
  // 먼저 서버에 프로젝트 DB 추가 요청을 보내고 projectId를 반환받아 Project 클래스 초기화
  // 이후 서버에 하위 프로젝트 DB 추가 요청을 보내고 subProjectId를 반환받아 SubProject 클래스를 초기화하여
  // Project 클래스의 subProjects 리스트에 추가
  Future<void> addProjectAndSubProjectByLLM(Project project, int userId) async {
    final Map<String, dynamic> projectBody = project.toJson();
    projectBody['user_id'] = userId;
    try {
      final projectResponse = await _apiClient.post(
        '/project/addProject',
        body: projectBody,
      );

      var projectJson = jsonDecode(projectResponse.body);
      var projectMessage = projectJson['message'];

      if (projectMessage == "Add Project Successed") {
        var projectId = projectJson['project_id'] as int;
        project = project.copyWith(projectId: projectId);
        addProjectToMap(project);

        for (int i = 0; i < project.subProjects!.length; i++) {
          var originalSubProject = project.subProjects![i]; // 원본 객체 가져오기

          final Map<String, dynamic> subProjectBody =
              originalSubProject.toJson();
          subProjectBody['project_id'] = projectId;

          try {
            final subProjectResponse = await _apiClient.post(
              '/project/addSubProject',
              body: subProjectBody,
            );

            var subProjecJson = jsonDecode(subProjectResponse.body);
            var subProjecMessage = subProjecJson['message'];

            if (subProjecMessage == "Add SubProject Successed") {
              var subProjectId = subProjecJson['subproject_id'] as int;

              project.subProjects![i] = originalSubProject.copyWith(
                subProjectId: subProjectId,
              );
            } else {
              throw Exception('Add SubProject Failed: $subProjecMessage');
            }
          } catch (e) {
            print('하위 프로젝트를 추가하는 과정에서 에러 발생: $e');
            rethrow;
          }
        }
        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else {
        throw Exception('Add Project Failed: $projectMessage');
      }
    } catch (e) {
      print('프로젝트를 추가하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 프로젝트를 DB에서 삭제하도록 요청을 보내는 메서드
  Future<void> deleteProject(int userId, int projectId) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'project_id': projectId,
    };

    try {
      final response = await _apiClient.post(
        '/project/deleteProject',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Delete Project Successed") {
        _projects.remove(projectId);
      } else {
        throw Exception('Delete Project Failed: $message');
      }
    } catch (e) {
      print('프로젝트를 삭제하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

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
        if (_projects.isNotEmpty) {
          print("_projects 모음집 안의 내용 : $_projects");
          _projects.forEach((key, value) {
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

  // 특정 장기 프로젝트의 정보를 변경하는 메서드
  Future<void> updateProject(int userId, Project project) async {
    final Map<String, dynamic> body = project.toJson();
    body["user_id"] = userId;

    try {
      final response = await _apiClient.post(
        '/project/updateProject',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Update SubProject Successed") {
        var result = json["result"];
        Project updateProject = Project.fromJson(result);
        updateProjectToList(project.projectId!, updateProject);
      } else {
        throw Exception('Update SubProject Failed: $message');
      }
    } catch (e) {
      print('프로젝트 정보를 수정하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
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
        var subProjectsJson = json['subProjects'];
        updateSubProjectListFromJson(projectId, subProjectsJson);
      } else {
        throw Exception('Get SubProject Failed: $message');
      }
    } catch (e) {
      print('하위 프로젝트 정보를 검색하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 프로젝트의 특정 날짜의 하위 프로젝트 목록을 DB에서 가져오는 메서드
  Future<List<SubProject>> getSubProjectByDate(
    int projectId,
    DateTime date,
  ) async {
    final Map<String, dynamic> body = {
      'project_id': projectId,
      'date': formatDate(date),
    };

    try {
      final response = await _apiClient.post(
        '/project/getSubProjectByDate',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Get SubProject By Date Successed") {
        var subProjectsJson = json['subProjects'];
        final subProjectList = jsonToSubProjectToList(subProjectsJson);
        print(subProjectList.length);
        return subProjectList;
      } else {
        throw Exception('Get SubProject By Date Failed: $message');
      }
    } on Exception catch (e) {
      if (e.toString().contains('404')) {
        return [];
      }
      print('하위 프로젝트 정보를 검색하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 장기 프로젝트의 서브 프로젝트를 DB에 추가하고 subProjectId를 반환받아
  // 해당 장기 프로젝트의 _subProjects 필드에 추가하는 메서드
  Future<void> addSubProject(
    int projectId,
    String subGoal,
    int maxDone,
    bool multiPerDay, {
    String? color,
    String? weekDay,
  }) async {
    SubProject subProject = SubProject(
      subGoal: subGoal,
      maxDone: maxDone,
      multiPerDay: multiPerDay,
      weekDay: weekDay,
      color: color,
    );

    final Map<String, dynamic> body = subProject.toJson();
    body["project_id"] = projectId;

    try {
      final response = await _apiClient.post(
        '/project/addSubProject',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Add SubProject Successed") {
        var subProjectId = json['subproject_id'] as int;
        subProject = subProject.copyWith(subProjectId: subProjectId);
        addSubProjectToList(projectId, subProject);
      } else {
        throw Exception('Add SubProject Failed: $message');
      }
    } catch (e) {
      print('하위 프로젝트를 추가하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 서브 프로젝트의 다중 생성을 하는 메서드
  // Future<void> addSubProjectMultiple(
  //   int projectId,
  //   String subGoal, {
  //   int? maxDone,
  //   bool? daily,
  //   List<String>? weekdays,
  // }) async {
  //   SubProject subProject = SubProject(subGoal: subGoal, maxDone: maxDone);

  //   final Map<String, dynamic> body = subProject.toJson();
  //   body.addAll({
  //     "project_id": projectId,
  //     "daily": daily,
  //     "weekdays": weekdays,
  //   });

  //   try {
  //     final response = await _apiClient.post(
  //       '/project/addSubProjectMultiple',
  //       body: body,
  //     );

  //     var json = jsonDecode(response.body);
  //     var message = json['message'];

  //     if (message == "Add Mutltiple SubProject Successed") {
  //       var subProjectJsonList = json['result'] as List<dynamic>;
  //       for (final subProjectJson in subProjectJsonList) {
  //         SubProject newSubProject = SubProject.fromJson(
  //           subProjectJson as Map<String, dynamic>,
  //         );
  //         projects![projectId]!.subProjects!.add(newSubProject);
  //       }
  //     } else {
  //       throw Exception('Add Mutltiple SubProject Failed: $message');
  //     }
  //   } catch (e) {
  //     print('하위 프로젝트를 다중 생성하는 과정에서 에러 발생: $e');
  //     // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
  //     rethrow;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // 특정 장기 프로젝트 하위 프로젝트의 정보를 수정하는 메서드
  Future<void> updateSubProjectEndpoint(
    int projectId,
    SubProject subProject,
  ) async {
    final Map<String, dynamic> body = subProject.toJson();
    body["project_id"] = projectId;

    try {
      final response = await _apiClient.post(
        '/project/updateSubProjectEndpoint',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Update SubProject Endpoint Successed") {
        updateSubProjectToList(projectId, subProject);
      } else {
        throw Exception('Update SubProject Endpoint Failed: $message');
      }
    } catch (e) {
      print('하위 프로젝트 정보를 수정하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 하위 프로젝트 진행도 증가
  Future<int> addSubProjectProgress(int subprojectId, DateTime date) async {
    final Map<String, dynamic> body = {
      "subproject_id": subprojectId,
      "date": formatDate(date),
    };

    try {
      final response = await _apiClient.post(
        '/project/addSubProjectProgress',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Add SubProject Progress Successed") {
        var result = json['result'];
        var count = result['count_for_date'] as int;

        notifyListeners();
        return count;
      } else {
        throw Exception('Add SubProject Progress Failed: $message');
      }
    } catch (e) {
      print('하위 프로젝트 진척도를 증가하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 하위 프로젝트 삭제
  Future<void> deleteSubProject(int projectId, int subProjectId) async {
    final Map<String, dynamic> body = {
      "project_id": projectId,
      "subproject_id": subProjectId,
    };

    try {
      final response = await _apiClient.post(
        '/project/deleteSubProject',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Delete SubProject Successed") {
        _projects[projectId]!.deleteSubProjectFromList(subProjectId);
      } else {
        throw Exception('message SubProject Progress Failed: $message');
      }
    } catch (e) {
      print('하위 프로젝트를 삭제하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 하위 프로젝트 진행도 감소
  Future<int> cancelSubProjectProgress(int subprojectId, DateTime date) async {
    final Map<String, dynamic> body = {
      "subproject_id": subprojectId,
      "date": formatDate(date),
    };

    try {
      final response = await _apiClient.post(
        '/project/cancelSubProjectProgress',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];
      if (message == "Cancel SubProject Progress Successed") {
        var result = json['result'];
        var count = result['count'] as int;

        return count;
      } else {
        throw Exception('Cancel SubProject Progress Failed: $message');
      }
    } catch (e) {
      print('하위 프로젝트 진척도를 감소하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 장기 프로젝트를 이를 저장하는 Map타입의 필드에 추가하는 메서드
  void addProjectToMap(Project project) {
    _projects[project.projectId!] = project;
    notifyListeners();
  }

  // json에 지정된 여러 개의 Project 정보들을 추출하여 이를 저장하는 Map 타입 필드에 저장하는 메서드
  void updateProjectMapFromJson(dynamic projectsJson) {
    // 기존 목록을 비움
    _projects.clear();
    final projectMap = projectsJson as Map;
    // 맵을 반복하며 모델의 fromJson 생성자를 사용
    projectMap.forEach((key, value) {
      final project = Project.fromJson(value as Map<String, dynamic>);
      _projects[project.projectId!] = project;
    });

    // UI에 변경사항 알림
    notifyListeners();
  }

  // json에 지정된 여러 개의 SubProject 정보들을 추출하여 이를 저장하는 List 타입 필드에 저장하는 메서드
  void updateSubProjectListFromJson(int projectId, dynamic subProjectsJson) {
    // 기존 목록을 비움
    _projects[projectId]!.subProjects!.clear();
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
    _projects[projectId]!.subProjects!.add(subProject);
    notifyListeners();
  }

  // 변경을 한 장기 프로젝트의 정보를 리스트에서 갱신
  void updateProjectToList(int projectId, Project updateProject) {
    projects![projectId] = projects![projectId]!.copyWith(
      title: updateProject.title,
      goal: updateProject.goal,
      startDate: updateProject.startDate,
      endDate: updateProject.endDate,
      timestamp: updateProject.timestamp,
    );
  }

  // 변경을 한 하위 프로젝트가 있는 장기 프로젝트의 하위 프로젝트 리스트를 갱신
  void updateSubProjectToList(int projectId, SubProject updateSubProject) {
    // updateSubProject와 subProjectId가 같은 첫 번째 요소의 인덱스를 찾습니다.
    final int index = projects![projectId]!.subProjects!.indexWhere(
      (element) => element.subProjectId == updateSubProject.subProjectId,
    );

    // 일치하는 요소를 찾았다면 (index가 -1이 아니라면)
    if (index != -1) {
      // 해당 인덱스의 요소를 전달받은 updateSubProject 객체로 교체합니다.
      projects![projectId]!.subProjects![index] = updateSubProject;
    }
  }

  List<SubProject> jsonToSubProjectToList(dynamic subProjectListJson) {
    List<SubProject> subProjectList = [];

    subProjectListJson = subProjectListJson as List<dynamic>;

    for (final subProjectJson in subProjectListJson) {
      final subProject = SubProject.fromJson(
        subProjectJson as Map<String, dynamic>,
      );
      subProjectList.add(subProject);
    }

    return subProjectList;
  }
}
