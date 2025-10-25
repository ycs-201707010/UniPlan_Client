import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:all_new_uniplan/services/everytime_service.dart'; // EverytimeService import
import 'package:all_new_uniplan/services/schedule_service.dart';

class ConflictResolutionPage extends StatelessWidget {
  const ConflictResolutionPage({super.key});

  // TimeOfDay를 'HH:mm' 형식으로 변환하는 헬퍼 함수
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    // EverytimeService의 상태를 watch하여 충돌 목록을 가져옵니다.
    final everytimeService = context.watch<EverytimeService>();
    final scheduleService = context.watch<ScheduleService>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('일정 충돌 해결')),
      // 화면 전체에 약간의 여백(padding)을 줍니다.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // 둥근 모서리와 테두리를 가진 컨테이너
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 배경색 (선택사항)
            borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
            border: Border.all(color: Colors.grey.shade300), // 테두리
            boxShadow: [
              // 약간의 그림자 효과 (선택사항)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // 컨테이너 내부의 내용물
          child: ListView.separated(
            itemCount: everytimeService.conflictingSchedules!.length,
            // 각 리스트 항목 사이에 구분선을 추가합니다.
            separatorBuilder: (context, index) => const Divider(height: 1),
            // 각 충돌 항목을 어떻게 그릴지 정의합니다.
            itemBuilder: (context, index) {
              final conflict = everytimeService.conflictingSchedules![index];
              final newSchedule = conflict.timetableSchedule;
              final existingSchedule = conflict.existingSchedule;

              // 각 항목은 Row로 구성 (정보 + 버튼)
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    // Expanded 위젯은 텍스트 정보가 버튼 영역을 제외한 나머지 공간을 차지하도록 합니다.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "'${newSchedule.title}' (새 시간표 일정)",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${DateFormat('MM/dd').format(newSchedule.date)} ${_formatTimeOfDay(newSchedule.startTime)} - ${_formatTimeOfDay(newSchedule.endTime)}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "'${existingSchedule.title}' (기존 일정)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          Text(
                            "${DateFormat('MM/dd').format(existingSchedule.date)} ${_formatTimeOfDay(existingSchedule.startTime)} - ${_formatTimeOfDay(existingSchedule.endTime)}",
                            style: TextStyle(color: Colors.redAccent[100]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16), // 정보와 버튼 사이 간격
                    // 버튼 영역
                    Row(
                      mainAxisSize: MainAxisSize.min, // 버튼 크기만큼만 공간 차지
                      children: [
                        // 초록색 V 버튼 (새 일정 추가)
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          tooltip: '시간표 일정 추가 (기존 일정 삭제)',
                          onPressed: () async {
                            // TODO: 실제 서비스 메서드 호출 (새 일정만 추가하는 로직)
                            await scheduleService.modifySchedule(
                              authService.currentUser!.userId,
                              existingSchedule,
                              newSchedule,
                            );
                            everytimeService.deleteConflitFromList(conflict);
                            print("새 일정 추가 선택됨: ${newSchedule.title}");

                            if (everytimeService.conflictingSchedules!.length ==
                                0) {
                              if (!context.mounted) return;

                              Navigator.of(context).pop(true);
                            }
                          },
                        ),
                        // 빨간색 X 버튼 (새 일정 무시)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: '시간표 일정 무시 (기존 일정 유지)',
                          onPressed: () async {
                            // TODO: 실제 서비스 메서드 호출 (새 일정을 무시하는 로직)
                            everytimeService.deleteConflitFromList(conflict);
                            print("새 일정 무시 선택됨: ${newSchedule.title}");

                            if (everytimeService.conflictingSchedules!.length ==
                                0) {
                              if (!context.mounted) return;

                              Navigator.of(context).pop(true);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
