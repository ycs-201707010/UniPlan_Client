// TODO : 챗봇 화면의 음성녹음 버튼을 클릭했을 시 출력될 BottomSheet

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wave_blob/wave_blob.dart';

// // 웨이브 효과를 위한 위젯
// class WaveEffect extends StatelessWidget {
//   final double size;
//   final double opacity;
//   final Color color;

//   const WaveEffect({
//     Key? key,
//     required this.size,
//     required this.opacity,
//     required this.color,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color.withValues(alpha: opacity),
//       ),
//     );
//   }
// }

class RecordingBottomSheet extends StatefulWidget {
  const RecordingBottomSheet({super.key});

  @override
  State<RecordingBottomSheet> createState() => _RecordingBottomSheetState();
}

class _RecordingBottomSheetState extends State<RecordingBottomSheet> {
  bool _isRecording = false; // 녹음 중인지 여부
  int _recordSeconds = 0; // 녹음 된 시간 (초 단위)
  Timer? _timer; // 타이머 객체

  bool _isDeciding = false; // 녹음이 완료되었는지 여부 (사용자는 여기에서 전송할지 되돌아갈지 선택.)

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        setState(() {});
      });
    });
  }

  // 타이머 시작
  void _startTimer() {
    _recordSeconds = 0; // 시작 시 시간 초기화
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  // 타이머 중지 함수
  void _stopTimer() {
    _timer?.cancel();
    _timer = null; // 타이머 객체 변수를 null로 초기화.
  }

  // 녹음 시작/중지 토글 함수
  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _startTimer();
      } else {
        _stopTimer();
        // ✅ 녹음이 끝났으므로, 결정 화면으로 전환
        _isDeciding = true;
      }
    });
  }

  // 녹음 시간을 '0:03' 형식으로 포맷 (UI에 출력하기 위함)
  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60; // 나누고 난 몫을 구하는 연산자를 사용해 분을 구함
    int remainingSeconds = seconds % 60; // 나머지 연산자를 사용해 초를 구함

    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 위젯이 제거될 때 타이머도 함께 정리함
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // 녹음 버튼
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        height: MediaQuery.of(context).size.width * 0.45,
        // decoration: BoxDecoration(
        //   color: const Color(0xFF5CE546),
        //   shape: BoxShape.circle,
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withValues(alpha: 0.15),
        //       blurRadius: 10,
        //       offset: const Offset(0, 5),
        //     ),
        //   ],
        // ),
        child: WaveBlob(
          blobCount: 3,
          amplitude: _isRecording ? 7000 : 0,
          scale: _isRecording ? 1.3 : 0.0,

          circleColors: const [
            /// If you don't want use Gradient, set just one color
            Color(0xFF5CE546),
          ],

          child:
              _isRecording
                  ? const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 50.0,
                  )
                  : const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 50.0,
                  ),
        ),
      ),
    );
  }

  // 기본적으로 Container에 들어갈 위젯
  Widget _normalContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 닫기 버튼
        Positioned(
          top: 10,
          left: 15,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => {Navigator.of(context).pop()},
          ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 웨이브 효과 (Stack 내부에 배치하면 버튼 뒤로 갈 수 있음)
            // if (_isRecording)
            //   Stack(
            //     alignment: Alignment.center,
            //     children: [
            //       // 가장 바깥 웨이브 (가장 투명하고 크게)
            //       WaveEffect(
            //         size: 200 + (_recordSeconds * 0.5), // 시간에 따라 크기 변화
            //         opacity: 0.1,
            //         color: Colors.green,
            //       ),
            //       // 중간 웨이브
            //       WaveEffect(
            //         size: 170 + (_recordSeconds * 0.2), // 시간에 따라 크기 변화
            //         opacity: 0.2,
            //         color: Colors.green,
            //       ),
            //       // 가장 안쪽 웨이브 (가장 불투명하고 작게)
            //       WaveEffect(size: 90, opacity: 0.3, color: Colors.green),
            //       // 실제 버튼 (맨 위에 렌더링)
            //       _buildRecordButton(),
            //     ],
            //   )
            // else
            _buildRecordButton(), // 녹음 중이 아닐 때는 웨이브 없이 버튼만
            const SizedBox(height: 30),

            // 텍스트 (상태에 따라 변경)
            Text(
              _isRecording
                  ? _formatDuration(_recordSeconds)
                  : '버튼을 눌러 녹음을 시작하세요',
              style: TextStyle(
                fontSize: _isRecording ? 32 : 20,
                fontWeight: FontWeight.bold,
                color: _isRecording ? Colors.black : Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 녹음 완료 후 사용자에게 선택지를 제공하는 위젯
  Widget _deciderContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 10,
          left: 15,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => {Navigator.of(context).pop()},
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO : 다시 들어볼 수 있게 플레이어 기능 추가?
            // 닫기 버튼
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.88,
              child: OutlinedButton(
                onPressed:
                    () => {
                      // TODO : 녹음 화면으로 되돌아가는 기능 만들기. setState() 사용할 것.
                      setState(() {
                        _isDeciding = false;
                      }),
                    },
                child: Text(
                  '다시 녹음하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.88,
              child: ElevatedButton(
                onPressed:
                    () => {
                      // TODO : 버튼 클릭 후 로딩 -> bottomSheet 닫힘 -> 채팅창 갱신의 흐름이 되도록 로직 구현하기
                    },
                child: Text(
                  '전송하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.45, // 화면 높이의 45% 사용
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),

      child: _isDeciding ? _deciderContainer() : _normalContainer(),
    );
  }
}
