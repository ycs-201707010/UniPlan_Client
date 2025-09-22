// lib/widgets/typing_indicator.dart

import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min, // 최소한의 너비만 차지
            children: List.generate(3, (index) {
              // 각 점의 애니메이션 시작 시간을 다르게 하여 순차적으로 움직이게 함
              final offset = (index * 0.2);
              final normalizedValue = (_controller.value - offset).clamp(
                0.0,
                1.0,
              );

              // 위아래로 부드럽게 움직이는 효과
              final y = -4 * (normalizedValue - 0.5).abs() * 2 + 2;

              return Transform.translate(
                offset: Offset(0, y),
                child: _buildDot(),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xEE8CFF1A),
        shape: BoxShape.circle,
      ),
    );
  }
}
