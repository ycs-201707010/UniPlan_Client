// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:all_new_uniplan/services/auth_service.dart';
// import 'package:all_new_uniplan/services/schedule_service.dart';
// import 'package:all_new_uniplan/services/everytime_service.dart';
// import 'package:all_new_uniplan/services/project_service.dart';

// class SchedulePageViewModel with ChangeNotifier {
//   // 의존하는 서비스들을 선언
//   final AuthService _authService;
//   final ScheduleService _scheduleService;
//   final EverytimeService _everytimeService;
//   final ProjectService _projectService;

//   // 생성자를 통해 필요한 서비스들을 주입받음
//   SchedulePageViewModel(
//     this._authService,
//     this._scheduleService,
//     this._everytimeService,
//     this._projectService,
//   );

//   // UI가 구독할 상태
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   // 페이지에 필요한 모든 데이터를 로드하는 단 하나의 메서드
//   Future<void> loadInitialData() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       if (_authService.isLoggedIn) {
//         final userId = _authService.currentUser!.userId;
//         // 여러 API 호출을 동시에 실행하여 로딩 시간 단축
//         await Future.wait([
//           _scheduleService.getSchedule(userId),
//           _everytimeService.getTimetable(userId),
//           _projectService.getProjectByUserId(userId),
//         ]);
//       }
//     } catch (e) {
//       print("초기 데이터 로딩 중 에러 발생: $e");
//       // 필요 시 에러 상태를 만들어 UI에 표시할 수 있음
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
