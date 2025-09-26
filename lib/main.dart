// ** 프로그램 진입점 **

import 'package:all_new_uniplan/screens/address_edit_page.dart';
import 'package:all_new_uniplan/screens/home.dart';
import 'package:all_new_uniplan/screens/welcome.dart';
import 'package:all_new_uniplan/services/chatbot_service.dart';
import 'package:all_new_uniplan/services/everytime_service.dart';
import 'package:all_new_uniplan/services/project_service.dart';
import 'package:all_new_uniplan/services/record_service.dart';
import 'package:all_new_uniplan/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 한국어/영어 UI 출력을 위한 패키지
import 'package:provider/provider.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/services/project_chatbot_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // 👇 여러 Provider를 관리하기 위한 MultiProvider
    MultiProvider(
      providers: [
        // 앱 전체에서 사용할 서비스들을 여기에 등록
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ScheduleService()),
        ChangeNotifierProvider(create: (context) => RecordService()),
        ChangeNotifierProvider(create: (context) => ProjectService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProxyProvider<ScheduleService, ChatbotService>(
          // create는 다른 Provider를 참조할 수 없으므로,
          // update에서 모든 것을 처리하는 것이 일반적입니다.
          // 초기 인스턴스를 여기서 생성할 수도 있습니다.
          create:
              (context) => ChatbotService(
                // create 시점에는 context.read를 통해 다른 Provider에 접근할 수 있습니다.
                context.read<ScheduleService>(),
              ),

          // ScheduleService가 변경될 때마다 update가 호출됩니다.
          update: (context, scheduleService, previousChatbotService) {
            // scheduleService 인스턴스를 ChatbotService에 전달하여
            // 항상 최신 상태를 유지하게 합니다.
            // previousChatbotService가 null이 아니라면 재사용할 수도 있습니다.
            return previousChatbotService ?? ChatbotService(scheduleService);
          },
        ),
        ChangeNotifierProxyProvider<ScheduleService, EverytimeService>(
          create:
              (context) => EverytimeService(context.read<ScheduleService>()),
          // update는 ScheduleService가 변경될 때 호출되며,
          // 기존 EverytimeService 인스턴스를 재사용하여 상태를 유지합니다.
          update:
              (context, scheduleService, previousEverytimeService) =>
                  previousEverytimeService ?? EverytimeService(scheduleService),
        ),
      ],

      child: const uniPlanApp(),
    ),
  );
}

class uniPlanApp extends StatelessWidget {
  const uniPlanApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'UniPlan',
      // 라이트모드의 테마
      theme: ThemeData(
        // 라이트모드의 컬러 테마를 정리함.

        // 어플 전체에 적용될 기본 폰트
        fontFamily: 'NanumSquare',

        // 배경색
        scaffoldBackgroundColor: Colors.white,

        // 채워진 버튼(ElevatedButton)의 색상 테마.
        // 버튼을 생성할 때 따로 Theme.of(context)를 통해 불러오지 않아도 된다.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6BE347), // ElevatedButton의 배경색
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            foregroundColor: Colors.white, // ElevatedButton의 텍스트/아이콘 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 채워지지 않은 버튼(Out)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: const Color(0xFF6BE347), width: 2),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(
            color: Color.fromARGB(255, 139, 139, 139),
            fontSize: 16,
          ),
        ),
      ), // end of light Theme
      // 다크모드의 테마
      darkTheme: ThemeData(
        // 어플 전체에 적용될 기본 폰트
        fontFamily: 'NanumSquare',

        // 배경색
        scaffoldBackgroundColor: Color(0xFF121212),

        // 채워진 버튼의 색상 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6BE347), // ElevatedButton의 배경색
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            foregroundColor: Colors.black, // ElevatedButton의 텍스트/아이콘 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 채워지지 않은 버튼(Out)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            // 테두리 색상.
            side: BorderSide(color: const Color(0xFF6BE347), width: 2),
            // 텍스트 색상은 다크모드의 어두운 배경에 잘 보이도록 테두리와 같은 밝은 색으로 변경.
            foregroundColor: const Color(0xFF6BE347),
            // 터치 시 물결 효과.
            overlayColor: const Color(0xFF6BE347).withValues(alpha: 0.1),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(
            color: Color.fromARGB(255, 139, 139, 139),
            fontSize: 16,
          ),
        ),
      ),

      themeMode: themeProvider.themeMode,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ko'), // ✅ 기본 언어를 한국어로 지정
      supportedLocales: const [
        Locale('ko'), // 한국어
        Locale('en'), // 영어 등 추가 가능
      ],
      home: Builder(
        builder: (context) {
          // 이 builder 내부의 context는 MultiProvider 아래에 있음이 보장됩니다.
          // 여기서 로그인 상태를 확인하고 적절한 페이지를 보여줄 수 있습니다.
          final authService = context.watch<AuthService>();

          // 로그인 상태에 따라 MainPage 또는 LoginPage를 보여줍니다.
          if (authService.isLoggedIn) {
            return HomeScreen(); // BottomNavigationBar를 포함하는 페이지
          } else {
            return welcomePage(); //welcomePage();
          }
        },
      ),
    );
  }
}
