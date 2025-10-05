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

- 일정 추가 시 저장된 장소/직접 입력 선택하는 기능
- 장기 프로젝트 화면/기능 구현 (table_calendar 라이브러리 사용)
  day가 한자리 수 일 때, select시 원 크기가 작은 디테일 수정하기
- 일정 생성 시, 색상 지정 및 랜덤 색상 기능 지원.
- Google Calendar API를 사용하여 공휴일 데이터 불러오기. (Schedule, Project 공통.)
- 장소로 이동하는 블럭 출력을 켜고 끌 수 있게.

## TroubleShooting

- 장소 저장 기능의 문제점 수정 (현재 원인 불명의 에러로 장소의 주소 설정 화면에서 Crash가 남.)
