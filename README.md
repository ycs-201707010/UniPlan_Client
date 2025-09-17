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

- 캘린더 시트 화면의 상단 날짜 부분, 오늘이 토요일 일요일일 시 강조 색상 변경 테스트.
- 일정 추가 시 저장된 장소/직접 입력 선택하는 기능
- 등록된 일정 1.5초간 홀드시 일정 상세보기 bottomSheet 출력
- Elevated, outlined Button 위젯을 사용한 것이 아닌 다른 위젯으로 구현된 버튼의 경우, 이 위젯으로 통일
- 장기 프로젝트 화면/기능 구현
- 다크모드 테마 설정
- 일정 생성 시, 색상 지정 및 랜덤 색상 기능 지원.

## TroubleShooting

- 장소 저장 기능의 문제점 수정 (현재 원인 불명의 에러로 장소의 주소 설정 화면에서 Crash가 남.)
