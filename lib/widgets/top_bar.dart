import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const TopBar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 기본 뒤로가기 제거
      elevation: 0, // 그림자 높이
      scrolledUnderElevation: 0, // 스크롤 해도 색상이 변하지 않게
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
