import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../services/directions_service.dart';
import '../ui/theme.dart';
import './editar_viagem_passageiros_screen.dart';

class DeslocamentoMapScreen extends StatefulWidget {
  const DeslocamentoMapScreen({super.key});

  @override
  State<DeslocamentoMapScreen> createState() => _DeslocamentoMapScreenState();
}

class _DeslocamentoMapScreenState extends State<DeslocamentoMapScreen> {
  final TextEditingController _origemCtrl = TextEditingController(text: 'Curitiba, PR, Brasil');
  final TextEditingController _destinoCtrl = TextEditingController(text: 'Hortolândia, SP, Brasil');
  int _zoom = 12;

  GoogleMapController? _mapController;
  LatLng _origemLatLng = const LatLng(-25.4284, -49.2733); // Curitiba
  LatLng _destinoLatLng = const LatLng(-22.8529, -47.2143); // Hortolândia (aprox)

  CameraPosition get _initialCamera => CameraPosition(target: _origemLatLng, zoom: _zoom.toDouble());

  Set<Marker> get _markers => {
    Marker(
      markerId: const MarkerId('origem'),
      position: _origemLatLng,
      infoWindow: const InfoWindow(title: 'Origem'),
    ),
    Marker(
      markerId: const MarkerId('destino'),
      position: _destinoLatLng,
      infoWindow: const InfoWindow(title: 'Destino'),
    ),
  };

  // Polyline de rota (carregada via Directions API). Fallback: linha reta.
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = const [];

  // Controle do mapa no Windows (flutter_map)
  final fm.MapController _fmController = fm.MapController();
  latlng.LatLng _fmCenter = const latlng.LatLng(-24.14065, -48.2448);
  double _fmZoom = 5;

  static const String _apiKey = 'AIzaSyCTCkJw0j8G0d0Q8biw9gjTQTfCPpZeNE0'; // TODO: substitua pela sua chave
  final DirectionsService _directions = const DirectionsService();

  @override
  void initState() {
    super.initState();
    // Garante que a rota seja carregada em todas as plataformas (Windows e mobile)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoute());

    // Centro inicial para Windows (média entre origem e destino)
    _fmCenter = latlng.LatLng((_origemLatLng.latitude + _destinoLatLng.latitude) / 2, (_origemLatLng.longitude + _destinoLatLng.longitude) / 2);
  }

  Future<void> _loadRoute() async {
    try {
      final points = await _directions.fetchRoute(origin: _origemLatLng, destination: _destinoLatLng, apiKey: _apiKey);
      setState(() {
        _routePoints = points;
        _polylines = {Polyline(polylineId: const PolylineId('rota'), points: points, color: Colors.blueAccent, width: 5)};
      });
      if (Platform.isWindows) {
        // Atualiza centro aproximado no Windows para a metade da rota
        if (_routePoints.isNotEmpty) {
          final mid = _routePoints[_routePoints.length ~/ 2];
          _fmCenter = latlng.LatLng(mid.latitude, mid.longitude);
        }
        // Mantém zoom atual e faz um pequeno ajuste de recenter
        _fmController.move(_fmCenter, _fmZoom);
      } else {
        await _fitToBounds();
      }
    } catch (e) {
      // Fallback para linha reta
      setState(() {
        _routePoints = <LatLng>[_origemLatLng, _destinoLatLng];
        _polylines = {Polyline(polylineId: const PolylineId('rota'), points: _routePoints, color: Colors.blueAccent, width: 4, geodesic: true)};
      });
      if (Platform.isWindows) {
        _fmCenter = latlng.LatLng((_origemLatLng.latitude + _destinoLatLng.latitude) / 2, (_origemLatLng.longitude + _destinoLatLng.longitude) / 2);
        _fmController.move(_fmCenter, _fmZoom);
      } else {
        await _fitToBounds();
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('Não foi possível obter a rota real: $e')));
    }
  }

  Future<void> _fitToBounds() async {
    if (_mapController == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _origemLatLng.latitude < _destinoLatLng.latitude ? _origemLatLng.latitude : _destinoLatLng.latitude,
        _origemLatLng.longitude < _destinoLatLng.longitude ? _origemLatLng.longitude : _destinoLatLng.longitude,
      ),
      northeast: LatLng(
        _origemLatLng.latitude > _destinoLatLng.latitude ? _origemLatLng.latitude : _destinoLatLng.latitude,
        _origemLatLng.longitude > _destinoLatLng.longitude ? _origemLatLng.longitude : _destinoLatLng.longitude,
      ),
    );
    await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
  }

  Future<void> _zoomIn() async {
    if (Platform.isWindows) {
      setState(() {
        _fmZoom = (_fmZoom + 1).clamp(0, 21);
      });
      _fmController.move(_fmCenter, _fmZoom);
    } else {
      if (_mapController == null) return;
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
      setState(() {
        _zoom = _zoom < 21 ? _zoom + 1 : 21;
      });
    }
  }

  Future<void> _zoomOut() async {
    if (Platform.isWindows) {
      setState(() {
        _fmZoom = (_fmZoom - 1).clamp(0, 21);
      });
      _fmController.move(_fmCenter, _fmZoom);
    } else {
      if (_mapController == null) return;
      await _mapController!.animateCamera(CameraUpdate.zoomOut());
      setState(() {
        _zoom = _zoom > 0 ? _zoom - 1 : 0;
      });
    }
  }

  @override
  void dispose() {
    _origemCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo: Google Map cobrindo toda a tela
          Positioned.fill(child: Platform.isWindows ? _buildWindowsMap() : _buildMobileMap()),

          // AppBar customizada
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                height: 48,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Deslocamento',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Campos de endereço sobrepostos
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 76, AppSpacing.md, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _AddressField(label: 'Origem', controller: _origemCtrl, onClear: () => setState(() => _origemCtrl.clear())),
                            const SizedBox(height: AppSpacing.sm),
                            _AddressField(label: 'Destino', controller: _destinoCtrl, onClear: () => setState(() => _destinoCtrl.clear())),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Botão de inversão
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            final tmp = _origemCtrl.text;
                            _origemCtrl.text = _destinoCtrl.text;
                            _destinoCtrl.text = tmp;
                            final tmpLatLng = _origemLatLng;
                            _origemLatLng = _destinoLatLng;
                            _destinoLatLng = tmpLatLng;
                            _loadRoute();
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const SizedBox(height: 36, width: 36, child: Icon(Icons.swap_vert, color: Colors.blue)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Controles de zoom
          Positioned(
            right: AppSpacing.md,
            bottom: 140,
            child: Material(
              color: Colors.white,
              elevation: 3,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                height: 98,
                width: 44,
                child: Column(
                  children: [
                    IconButton(icon: const Icon(Icons.add), onPressed: _zoomIn),
                    const Divider(height: 1),
                    IconButton(icon: const Icon(Icons.remove), onPressed: _zoomOut),
                  ],
                ),
              ),
            ),
          ),

          // Painel inferior persistente
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.lg), topRight: Radius.circular(AppRadius.lg)),
                boxShadow: [appShadow(0.08)],
              ),
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EditarViagemPassageirosScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
                        child: const Text('Salvar e Avançar', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMap() {
    return GoogleMap(
      initialCameraPosition: _initialCamera,
      markers: _markers,
      polylines: _polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onCameraMove: (pos) {
        final z = pos.zoom.round();
        if (z != _zoom) {
          setState(() => _zoom = z);
        }
      },
      onMapCreated: (c) {
        _mapController = c;
        _loadRoute();
      },
    );
  }

  Widget _buildWindowsMap() {
    final routeLL = _routePoints.map((p) => latlng.LatLng(p.latitude, p.longitude)).toList(growable: false);

    return fm.FlutterMap(
      mapController: _fmController,
      options: fm.MapOptions(initialCenter: _fmCenter, initialZoom: _fmZoom),
      children: [
        fm.TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']),
        fm.PolylineLayer(
          polylines: [
            fm.Polyline(points: routeLL.isNotEmpty ? routeLL : [_fmCenter], color: Colors.blueAccent, strokeWidth: 4),
          ],
        ),
        fm.MarkerLayer(
          markers: [
            fm.Marker(width: 40, height: 40, point: latlng.LatLng(_origemLatLng.latitude, _origemLatLng.longitude), child: _pin(Colors.green)),
            fm.Marker(width: 40, height: 40, point: latlng.LatLng(_destinoLatLng.latitude, _destinoLatLng.longitude), child: _pin(Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _pin(Color color) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [appShadow(0.12)]),
      child: const Icon(Icons.location_on, color: Colors.white),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({required this.label, required this.controller, required this.onClear});
  final String label;
  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [appShadow(0.06)],
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration.collapsed(hintText: ''),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClear),
        ],
      ),
    );
  }
}
