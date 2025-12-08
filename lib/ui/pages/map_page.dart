import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/firebase_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();

  static const CameraPosition _kDefaultPosition = CameraPosition(
    target: LatLng(-23.550520, -46.633308), 
    zoom: 14.4746,
  );

  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  LatLng? _currentPosition;
  bool _loading = true;

  // Cores
  static const Color primaryColor = Color(0xFFF9D406);
  static const Color backgroundDark = Color(0xFF23200F);
  
  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#2c2c2c"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#8a8a8a"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return; 

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
    });

    try {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 16.0),
      ));
    } catch (e) {}
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      };
    });
  }

  Future<void> _goToMarker() async {
    if (_selectedLocation != null) {
      await _sendToFirebase(_selectedLocation!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enviando carro para o destino selecionado...")),
        );
      }
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selecione um ponto no mapa primeiro.")),
        );
      }
    }
  }

  Future<void> _comeToMe() async {
    if (_currentPosition != null) {
      _onMapTap(_currentPosition!);
      await _sendToFirebase(_currentPosition!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Função 'Me Encontre' ativada! Carro vindo até você.")),
        );
      }
    } else {
      _determinePosition();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Obtendo sua localização... Tente novamente.")),
        );
      }
    }
  }

  Future<void> _sendToFirebase(LatLng target) async {
    await FirebaseService.destinoXRef.set(target.latitude);
    await FirebaseService.destinoYRef.set(target.longitude);
    await FirebaseService.modoDirecaoRef.set("automatico");
    await FirebaseService.cockpitRef.set(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          _loading 
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _currentPosition != null 
                      ? CameraPosition(target: _currentPosition!, zoom: 15) 
                      : _kDefaultPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    controller.setMapStyle(_darkMapStyle);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onTap: _onMapTap,
                  markers: _markers,
                ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.arrow_back, color: primaryColor), onPressed: () => Navigator.pop(context)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.search, color: primaryColor),
                                            hintText: 'Procurar um destino',
                                            hintStyle: TextStyle(color: Colors.white70),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      children: [
                                        InkWell(onTap: () async {final c = await _controller.future; c.animateCamera(CameraUpdate.zoomIn());}, child: const SizedBox(width: 40, height: 40, child: Icon(Icons.add, color: Colors.white))),
                                        Container(height: 1, width: 30, color: Colors.white12),
                                        InkWell(onTap: () async {final c = await _controller.future; c.animateCamera(CameraUpdate.zoomOut());}, child: const SizedBox(width: 40, height: 40, child: Icon(Icons.remove, color: Colors.white))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                                    child: InkWell(onTap: _determinePosition, child: const SizedBox(width: 40, height: 40, child: Icon(Icons.my_location, color: Colors.white))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _selectedLocation != null
                                    ? "Destino: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}"
                                    : "Selecione um destino no mapa",
                                style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _selectedLocation != null ? _goToMarker : null,
                                icon: const Icon(Icons.pin_drop),
                                label: const Text("Ir para Destino Selecionado", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor.withOpacity(0.5)),
                                  backgroundColor: primaryColor.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _comeToMe,
                                icon: const Icon(Icons.person_pin_circle),
                                label: const Text("Me Encontre", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: backgroundDark,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
