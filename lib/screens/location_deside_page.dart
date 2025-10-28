// ** 사용자 일정 수행 장소 설정 페이지 **

import 'dart:convert';
import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationDesidePage extends StatefulWidget {
  const LocationDesidePage({super.key});

  @override
  _LocationDesidePageState createState() => _LocationDesidePageState();
}

class _LocationDesidePageState extends State<LocationDesidePage> {
  late GoogleMapController mapController;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> suggestions = [];

  LatLng currentPosition = LatLng(37.5665, 126.9780); // 기본: 서울
  Marker? selectedMarker;

  final String apiKey = ''; // 여기에 키 입력

  bool showSuggestions = false; // 검색 중인지 여부를 판단하는 상태 변수

  @override
  void initState() {
    super.initState();
    _getMyLocation();
  }

  Future<void> _getMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied)
        return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(currentPosition, 16),
    );
  }

  // 검색 창에 주소 검색 시 작동하는 메서드.
  Future<void> fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) return;

    print("검색 요청: $input");

    setState(() {
      showSuggestions = true;
    });

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&language=ko';
    final response = await http.get(Uri.parse(url));

    print("응답 코드: ${response.statusCode}");
    print("응답 본문: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final predictions = json['predictions'] as List;
      print("예상 결과 수: ${predictions.length}");
      setState(() {
        suggestions =
            predictions
                .map(
                  (e) => {
                    'description': e['description'].toString(),
                    'place_id': e['place_id'].toString(),
                  },
                )
                .toList();
      });
    }
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&language=ko';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final location = json['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      setState(() {
        selectedMarker = Marker(
          markerId: MarkerId(placeId),
          position: latLng,
          infoWindow: InfoWindow(title: json['result']['name']),
        );
        currentPosition = latLng;
        suggestions = [];
      });

      mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: context.l10n.selectLocationHint),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => mapController = controller,
            markers: selectedMarker != null ? {selectedMarker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // ✅ 검색창 + Enter 키 입력 처리
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (value) {
                      (fetchPlaceSuggestions(value));
                    }, // ✅ 엔터로도 검색되게
                    decoration: InputDecoration(
                      hintText: context.l10n.locationSearchHint,
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (showSuggestions)
                  Container(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    constraints: BoxConstraints(maxHeight: 300),
                    child:
                        suggestions.isNotEmpty
                            ? ListView(
                              shrinkWrap: true,
                              children:
                                  suggestions.map((s) {
                                    return ListTile(
                                      title: Text(s['description']!),
                                      onTap: () {
                                        searchController.text =
                                            s['description']!;
                                        setState(() {
                                          showSuggestions = false;
                                        });
                                        fetchPlaceDetails(s['place_id']!);
                                      },
                                    );
                                  }).toList(),
                            )
                            : ListTile(
                              title: Text(context.l10n.searchNoResults),
                              subtitle: Text(context.l10n.searchTryAgain),
                            ),
                  ),
              ],
            ),
          ),

          // 장소 확정 버튼
          if (selectedMarker != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, {
                    'address': searchController.text,
                    'lat': selectedMarker!.position.latitude,
                    'lng': selectedMarker!.position.longitude,
                  });
                },
                icon: Icon(Icons.check),
                label: Text(context.l10n.desideLocation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // ✅ GPS 및 기타 버튼
          Positioned(
            bottom: 170,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "gps",
                  mini: true,
                  onPressed: () async {
                    bool serviceEnabled =
                        await Geolocator.isLocationServiceEnabled();
                    LocationPermission permission =
                        await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) return;

                    Position position = await Geolocator.getCurrentPosition();
                    final LatLng newPos = LatLng(
                      position.latitude,
                      position.longitude,
                    );
                    setState(() => currentPosition = newPos);
                    mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(newPos, 16),
                    );
                  },
                  child: Icon(Icons.gps_fixed),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "another",
                  mini: true,
                  onPressed: () {
                    // 다른 기능 버튼으로 확장 가능
                  },
                  child: Icon(Icons.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
