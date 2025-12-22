import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'polyline_decoder.dart';

class DirectionsService {
  const DirectionsService();

  /// Busca rota entre origem e destino usando Google Directions API.
  /// Retorna lista de pontos (LatLng) da polyline "overview".
  Future<List<LatLng>> fetchRoute({required LatLng origin, required LatLng destination, required String apiKey}) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=driving'
      '&key=$apiKey',
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Directions API falhou: HTTP ${resp.statusCode}');
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final status = data['status'] as String?;
    if (status != 'OK') {
      throw Exception('Directions API status: $status');
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw Exception('Nenhuma rota encontrada');
    }

    final overview = routes.first['overview_polyline'] as Map<String, dynamic>;
    final encoded = overview['points'] as String;
    return decodePolyline(encoded);
  }
}
