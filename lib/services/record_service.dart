import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:all_new_uniplan/api/api_client.dart'; // ApiClient 경로 확인 필요

class RecordService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamSubscription? _progressSubscription;
  bool _isInitialized = false;

  // --- 상태 변수들 ---
  bool _isRecording = false;
  bool _isProcessing = false; // 녹음 중지 후 STT 처리 중 상태
  Duration _recordDuration = Duration.zero;

  // --- 외부 공개 Getter들 ---
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String get recordDurationText => _formatDuration(_recordDuration);

  //  late String _filePath;
  String? _filePath;
  String? get filePath => _filePath;

  /// 서비스 초기화
  Future<bool> initialize() async {
    // 1. 현재 마이크 권한 상태를 먼저 확인합니다. (팝업 X)
    final status = await Permission.microphone.status;

    // 2. 권한이 이미 허용된 경우
    if (status.isGranted) {
      print("마이크 권한이 이미 허용되어 있습니다.");
    }
    // 3. 권한이 허용되지 않은 경우 (denied, permanentlyDenied 등)
    else {
      // 3-1. 사용자에게 권한을 요청합니다. (팝업 O)
      final newStatus = await Permission.microphone.request();

      // 3-2. 사용자가 '영구적으로 거부'를 선택한 경우
      if (newStatus.isPermanentlyDenied) {
        // 사용자가 직접 앱 설정에 가서 권한을 켜도록 안내해야 합니다.
        print("마이크 권한이 영구적으로 거부되었습니다. 앱 설정에서 허용해주세요.");
        // openAppSettings(); // 이 함수를 호출하여 앱 설정 화면으로 바로 이동시킬 수 있습니다.
        throw "permanent deny";
      }

      // 3-3. 사용자가 권한을 거부한 경우
      if (!newStatus.isGranted) {
        return false;
      }
    }

    // 이 지점에 도달했다면 권한이 허용된 것이므로, 레코더를 초기화합니다.
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    _isInitialized = true;
    return true;
  }

  /// 녹음 시작/중지 토글
  Future<void> toggleRecording() async {
    if (!_isInitialized || _isProcessing) return;
    _isRecording ? await _stopRecording() : await _startRecording();
  }

  /// 녹음 시작
  Future<void> _startRecording() async {
    // 1. 앱의 문서 저장 경로를 가져옵니다.
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'record_${DateTime.now().millisecondsSinceEpoch}.aac';

    // 2. 전체 파일 경로를 생성하여 _filePath에 저장합니다.
    _filePath = '${directory.path}/$fileName';

    // ✅ 경로가 할당되었는지 확인
    print(">> _filePath 할당됨: $_filePath");

    await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);

    // 진행 상태 스트림 구독 시작
    _progressSubscription = _recorder.onProgress!.listen((disposition) {
      _recordDuration = disposition.duration;
      notifyListeners();
    });

    _isRecording = true;
    notifyListeners();
  }

  /// 녹음 중지
  Future<void> _stopRecording() async {
    _isProcessing = true;
    notifyListeners();

    try {
      // ✅ 1. stopRecorder()가 반환하는 최종 파일 경로를 변수에 저장합니다.
      final path = await _recorder.stopRecorder();
      print(">> _stopRecorder 가 반환한 경로: $path");

      // ✅ 2. 반환된 경로를 _filePath에 할당합니다.
      _filePath = path;

      print('녹음 완료. 최종 경로: $_filePath');
      _progressSubscription?.cancel(); // 스트림 구독 취소
      _isRecording = false;
      _recordDuration = Duration.zero;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// 녹음을 강제로 중지하고 모든 상태를 초기화 하는 함수.
  Future<void> forceStopRecording() async {
    // 녹음 중이 아니면 아무것도 하지 않음
    if (!_isRecording) return;

    print("녹음을 강제로 중지합니다...");

    try {
      // 1. flutter_sound 레코더를 중지시킵니다.
      await _recorder.stopRecorder();
    } catch (e) {
      print('레코더 중지 중 오류 발생 (무시 가능): $e');
    } finally {
      // 2. 스트림 구독을 취소합니다.
      _progressSubscription?.cancel();
      _progressSubscription = null;

      // 3. 모든 상태 변수를 초기값으로 되돌립니다.
      _isRecording = false;
      _isProcessing = false;
      _recordDuration = Duration.zero;

      // 4. UI에 상태 변경을 즉시 알립니다.
      notifyListeners();
    }
  }

  // Duration을 MM:SS 형식으로 변환
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _progressSubscription?.cancel();
    super.dispose();
  }

  Future<String> getSpeechToText() async {
    // ✅ _filePath가 null이면 녹음된 파일이 없다는 뜻이므로 에러를 발생시킵니다.
    if (_filePath == null) {
      throw Exception('녹음된 파일의 경로가 존재하지 않습니다.');
    }

    try {
      final response = await _apiClient.multiPost(
        '/chatbot/audioRecord',
        'audio_file',
        filePath: _filePath!,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Response Successed") {
        String stt = json['output'];

        return stt;
      } else {
        throw Exception('Response Failed: $message');
      }
    } catch (e) {
      print('API 전송 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }
}
