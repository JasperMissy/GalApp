import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/map/map_marker_builder.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/views/shared/empty_state.dart';
import 'package:latlong2/latlong.dart';

/// Geographische Übersicht mit Filtern (Kunden, offene Aufträge, Kollegen).
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.initialFilter = MapFilter.kunden});

  final MapFilter initialFilter;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late MapFilter _filter = widget.initialFilter;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Client>> clients = ref.watch(clientsProvider);
    final AsyncValue<List<Order>> orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karte'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                for (final MapFilter f in MapFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabel(f)),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(clients, orders),
    );
  }

  Widget _buildBody(
    AsyncValue<List<Client>> clients,
    AsyncValue<List<Order>> orders,
  ) {
    if (_filter == MapFilter.kollegen) {
      return const EmptyState(
        icon: Icons.groups_outlined,
        title: 'Noch keine Kollegen',
        message: 'Die Kollegen-Übersicht folgt mit der Kollegen-Datenbank.',
      );
    }

    if (clients.isLoading || orders.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (clients.hasError || orders.hasError) {
      return const EmptyState(
        icon: Icons.error_outline,
        title: 'Daten nicht verfügbar',
        message: 'Bitte versuchen Sie es erneut.',
      );
    }

    final List<MapMarkerData> markers = buildMapMarkers(
      clients: clients.value ?? const <Client>[],
      orders: orders.value ?? const <Order>[],
      filter: _filter,
    );

    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(51.1657, 10.4515),
            initialZoom: 6,
            onMapReady: () => _fitMarkers(markers),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'de.galabau.app',
            ),
            MarkerLayer(
              markers: <Marker>[
                for (final MapMarkerData m in markers) _markerFor(m),
              ],
            ),
          ],
        ),
        if (markers.isEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _filter == MapFilter.kunden
                            ? 'Noch keine Kunden mit Adresse. Legen Sie Kunden an.'
                            : 'Noch keine offenen Aufträge mit Adresse.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Marker _markerFor(MapMarkerData m) => Marker(
        point: LatLng(m.lat, m.lon),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () => _showInfo(m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                m.kind == MapMarkerKind.kunde
                    ? Icons.location_on
                    : Icons.assignment_turned_in,
                color: m.kind == MapMarkerKind.kunde
                    ? Colors.blue
                    : Colors.orange,
                size: 34,
              ),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    m.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _fitMarkers(List<MapMarkerData> markers) {
    if (markers.isEmpty) return;
    final LatLngBounds bounds = LatLngBounds.fromPoints(
      <LatLng>[for (final MapMarkerData m in markers) LatLng(m.lat, m.lon)],
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  void _showInfo(MapMarkerData m) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: ListTile(
          leading: Icon(
            m.kind == MapMarkerKind.kunde
                ? Icons.location_on
                : Icons.assignment_turned_in,
          ),
          title: Text(m.title),
          subtitle: Text(m.subtitle),
        ),
      ),
    );
  }

  String _filterLabel(MapFilter f) => switch (f) {
        MapFilter.kunden => 'Kunden',
        MapFilter.offeneAuftraege => 'Offene Aufträge',
        MapFilter.kollegen => 'Kollegen',
      };
}
