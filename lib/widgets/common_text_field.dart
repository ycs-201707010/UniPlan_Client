import 'package:flutter/material.dart';

class CommonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType inputType;
  final bool obscureText; // 처음에 가릴지 여부 (비밀번호면 true)

  const CommonTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.inputType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  // 현재 텍스트가 가려져 있는지 여부를 관리하는 상태 변수
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때, 부모가 전달한 설정값을 초기 상태로 사용
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.inputType,

      // ✅ 상태 변수에 따라 가림 여부 결정
      obscureText: _isObscure,

      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,

        // ✅ 비밀번호 입력창일 경우(obscureText == true)에만 눈 모양 아이콘 표시
        suffixIcon:
            widget.obscureText
                ? IconButton(
                  icon: Icon(
                    // 가려져 있으면 '눈', 보여지고 있으면 '눈 감기' 아이콘
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      // 상태 토글 (true <-> false)
                      _isObscure = !_isObscure;
                    });
                  },
                )
                : null, // 비밀번호가 아니면 아이콘 없음
        // --- 테두리 스타일 ---
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
