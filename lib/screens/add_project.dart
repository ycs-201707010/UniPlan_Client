// import 'package:all_new_uniplan/widgets/top_bar.dart';
// import 'package:flutter/material.dart';

// class AddProject extends StatefulWidget {
//   const AddProject({super.key});

//   @override
//   State<AddProject> createState() => _AddProjectState();
// }

// class _AddProjectState extends State<AddProject> {
//   @override
//   Widget build(BuildContext context) {
//     String barTitle = '일정 추가하기';
//     String buttonTitle = '일정 추가하기';

//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;

//     return Scaffold(
//       appBar: TopBar(title: barTitle),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("일정 제목"),
//               TextField(controller: titleController),
//               const SizedBox(height: 16),
//               const Text("수행일"),
//               TextField(
//                 controller: dateController,
//                 decoration: InputDecoration(
//                   suffixIcon: Icon(Icons.calendar_today),
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: 14,
//                   ), // ✅ 세로 정렬 중앙
//                 ),
//                 readOnly: true,
//                 onTap: () {
//                   // showDatePicker
//                   pickDate(context);
//                 },
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: startTimeController,
//                       readOnly: true,
//                       decoration: InputDecoration(labelText: '시작 시간'),
//                       onTap: () => pickTime(context, true),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       controller: endTimeController,
//                       readOnly: true,
//                       decoration: InputDecoration(labelText: '종료 시간'),
//                       onTap: () => pickTime(context, false),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               const Text("수행 장소"),
//               // TextField(
//               //   controller: locationController,
//               //   readOnly: true,
//               //   decoration: const InputDecoration(
//               //     suffixIcon: Icon(Icons.place),
//               //     contentPadding: EdgeInsets.symmetric(vertical: 14),
//               //     focusedBorder: UnderlineInputBorder(
//               //       borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
//               //     ),
//               //   ),
//               //   onTap: pickLocation,
//               // ),
//               // ✅ 2. 기존 TextField를 DropdownButtonFormField로 교체
//               DropdownButtonFormField<Object>(
//                 // 현재 선택된 값을 표시 (UI 업데이트용)
//                 value: _selectedPlace,
//                 isExpanded: true, // 텍스트가 길 경우를 대비
//                 decoration: const InputDecoration(
//                   suffixIcon: Icon(Icons.place),
//                   contentPadding: EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 hint: const Text('장소 선택'), // 아무것도 선택되지 않았을 때 표시될 텍스트
//                 // ✅ 3. 아이템 목록 동적 생성
//                 items: [
//                   // '직접 선택' 메뉴 아이템을 맨 위에 추가
//                   const DropdownMenuItem<Object>(
//                     value: 'direct_select', // 특수 값으로 지정
//                     child: Text('📍 직접 선택'),
//                   ),
//                   // PlaceService에서 불러온 장소 목록으로 메뉴 아이템 생성
//                   ...places.map<DropdownMenuItem<Object>>((Place place) {
//                     return DropdownMenuItem<Object>(
//                       value: place, // 값으로 Place 객체 자체를 사용
//                       child: Text(place.name),
//                     );
//                   }),
//                 ],

//                 // ✅ 4. 항목을 선택했을 때 실행될 콜백 함수
//                 onChanged: (Object? newValue) {
//                   if (newValue is Place) {
//                     // 저장된 장소를 선택한 경우
//                     setState(() {
//                       _selectedPlace = newValue;
//                       locationController.text = newValue.address;
//                     });
//                   } else if (newValue == 'direct_select') {
//                     // '직접 선택'을 선택한 경우
//                     setState(() {
//                       _selectedPlace = null; // 선택 상태 초기화
//                       locationController.clear(); // 텍스트 필드 비우기
//                     });
//                     pickLocation(); // 기존의 지도 페이지 여는 함수 호출
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               const Text("메모"),
//               TextField(maxLines: 5, controller: memoController),
//               const SizedBox(height: 24),

//               Text("색상 선택"),
//               SizedBox(height: 15),

//               GestureDetector(
//                 onTap: () => pickColor('ColorPicker'),
//                 child: Container(
//                   width: 150,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: _selectedColor,
//                     border: Border.all(
//                       color: Theme.of(context).colorScheme.outline,
//                     ),
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       // ✅ 하단 버튼 (키보드에 따라 위로 밀려 올라감)
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.only(
//           top: 10,
//           left: 20,
//           right: 20,
//           bottom: bottomInset > 0 ? bottomInset + 20 : 20, // 키보드가 올라올 때 +10 여유
//         ),
//         child: SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton(
//             // ** 눌렀을 때 이벤트 **
//             onPressed: () async {
//               if (originalSchedule != null) {
//                 modifySchedule();
//               } else {
//                 addSchedule();
//               }
//             },

//             child: Text(
//               buttonTitle,
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
