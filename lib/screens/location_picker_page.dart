import 'dart:developer';

import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_places_api_flutter/google_places_api_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedPosition;
  final String _pickedAddress = '';
  GoogleMapController? _mapController;

  final String apiKey = 'AIzaSyCj47z5fjQ5s7gNZzwVK9dnrktS516IgRs'; // 실 사용 API 키

  bool showSuggestions = false; // 검색 중인지 여부를 판단하는 상태 변수

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: '장소 선택'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
            // 주소 자동완성 입력 필드
            child: PlaceSearchField(
              apiKey: apiKey,
              isLatLongRequired: true, // Fetch lat/long with place details
              webCorsProxyUrl:
                  "https://cors-anywhere.herokuapp.com", // Optional for web
              onPlaceSelected: (prediction, details) async {},
              decorationBuilder: (context, child) {
                return Material(
                  type: MaterialType.card,
                  elevation: 4,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  child: child,
                );
              },
              itemBuilder:
                  (context, prediction) => ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(
                      prediction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            ),
          ),

          // 🗺 지도 표시
          Expanded(
            child:
                _pickedPosition == null
                    ? const Center(child: Text("장소를 검색해 주세요."))
                    : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _pickedPosition!,
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("selected"),
                          position: _pickedPosition!,
                        ),
                      },
                      onMapCreated: (controller) => _mapController = controller,
                    ),
          ),

          // ✅ 장소 확정 버튼
          if (_pickedPosition != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, {
                    'lat': _pickedPosition!.latitude,
                    'lng': _pickedPosition!.longitude,
                    'address': _pickedAddress,
                  });
                },
                icon: const Icon(Icons.check),
                label: const Text("이 장소로 확정하기"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
