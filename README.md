# UniPlan_Client

안양대학교 소프트웨어학과 2025학년도 4학년 졸업작품 클라이언트

## 폴더 구조 설명

lib/
├── main.dart
├── screens/ ## 화면 UI 구성
├── services/ ## 로그인, 회원가입 등 서버와 통신 및 상태 저장
└── widgets/ ## UI를 구성하는 모듈화된 위젯

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## TO-DO List

- 장기 프로젝트 화면/기능 구현 (table_calendar 라이브러리 사용)
- Google Calendar API를 사용하여 공휴일 데이터 불러오기. (Schedule, Project 공통.)
- 장소로 이동하는 시간을 표시한 블럭의 출력을 켜고 끌 수 있게.
- (add_schedule.dart) DropDownList에서 장소 선택시 메서드에 place의 name이 들어가도록 변경
- (everytime_link_page.dart) 시작 날짜를 정하지 않으면 종료 일자를 정할 수 없으며, 시작 날짜 이전으로 정하지 못하게
- (everytime_link_page.dart) 오늘 날짜 이전으로 정하지 못하게 되어있는데, 이거 해결하기 (일정간 충돌도 보완)
  유효성 검사 로직을 만들 것.
- (project_page.dart) 서브 프로젝트의 증감을 사용자가 어떻게 조작하는지 도움말 버튼 부착하기
