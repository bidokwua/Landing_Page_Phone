
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/event_details_sheet_widget.dart';
import './widgets/map_controls_widget.dart';
import './widgets/zone_drawing_controls_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.satellite;
  bool _isDrawingMode = false;
  String _drawingZoneType = 'no-go'; // 'no-go' or 'priority'

  // Robot location and tracking
  final LatLng _robotLocation = const LatLng(37.7749, -122.4194);
  final List<LatLng> _robotTrail = [];

  // Property boundary points
  final List<LatLng> _propertyBoundary = [
    const LatLng(37.7750, -122.4200),
    const LatLng(37.7755, -122.4200),
    const LatLng(37.7755, -122.4190),
    const LatLng(37.7750, -122.4190),
  ];

  // Zones
  final List<List<LatLng>> _noGoZones = [];
  final List<List<LatLng>> _priorityZones = [];
  final List<LatLng> _currentDrawingPoints = [];

  // Heat/smoke events
  final List<Map<String, dynamic>> _heatEvents = [
    {
      "id": 1,
      "location": const LatLng(37.7752, -122.4195),
      "type": "heat",
      "temperature": 145.0,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "severity": "high",
    },
    {
      "id": 2,
      "location": const LatLng(37.7748, -122.4192),
      "type": "smoke",
      "smokeIndex": 8.5,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 12)),
      "severity": "medium",
    },
  ];

  Map<String, dynamic>? _selectedEvent;
  final bool _isEmergencyMode = false;
  bool _isManualDriveMode = false;

  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Add robot trail
    _robotTrail.addAll([
      const LatLng(37.7745, -122.4198),
      const LatLng(37.7747, -122.4196),
      const LatLng(37.7749, -122.4194),
    ]);

    _updateMapElements();
  }

  void _updateMapElements() {
    _markers.clear();
    _polygons.clear();
    _polylines.clear();

    // Add robot marker
    _markers.add(
      Marker(
        markerId: const MarkerId('robot'),
        position: _robotLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Firefly Robot',
          snippet: 'Battery: 87% | Status: Patrolling',
        ),
      ),
    );

    // Add heat/smoke event markers
    for (var event in _heatEvents) {
      _markers.add(
        Marker(
          markerId: MarkerId('event_${event["id"]}'),
          position: event["location"] as LatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            event["type"] == "heat"
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueRed,
          ),
          onTap: () => _showEventDetails(event),
        ),
      );
    }

    // Add property boundary polygon
    if (_propertyBoundary.isNotEmpty) {
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('property_boundary'),
          points: _propertyBoundary,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withValues(alpha: 0.1),
        ),
      );
    }

    // Add no-go zones
    for (int i = 0; i < _noGoZones.length; i++) {
      _polygons.add(
        Polygon(
          polygonId: PolygonId('no_go_$i'),
          points: _noGoZones[i],
          strokeColor: Colors.red,
          strokeWidth: 2,
          fillColor: Colors.red.withValues(alpha: 0.2),
        ),
      );
    }

    // Add priority zones
    for (int i = 0; i < _priorityZones.length; i++) {
      _polygons.add(
        Polygon(
          polygonId: PolygonId('priority_$i'),
          points: _priorityZones[i],
          strokeColor: Colors.green,
          strokeWidth: 2,
          fillColor: Colors.green.withValues(alpha: 0.2),
        ),
      );
    }

    // Add robot trail polyline
    if (_robotTrail.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('robot_trail'),
          points: _robotTrail,
          color: Colors.blue.withValues(alpha: 0.6),
          width: 3,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _toggleMapType() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentMapType = _currentMapType == MapType.satellite
          ? MapType.normal
          : MapType.satellite;
    });
  }

  void _toggleDrawingMode(String zoneType) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isDrawingMode && _drawingZoneType == zoneType) {
        _isDrawingMode = false;
        _currentDrawingPoints.clear();
      } else {
        _isDrawingMode = true;
        _drawingZoneType = zoneType;
        _currentDrawingPoints.clear();
      }
    });
  }

  void _onMapTap(LatLng position) {
    if (_isDrawingMode) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentDrawingPoints.add(position);
      });
    } else if (!_isManualDriveMode) {
      // Set waypoint
      _setWaypoint(position);
    }
  }

  void _setWaypoint(LatLng position) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Waypoint set at ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _completeZoneDrawing() {
    if (_currentDrawingPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least 3 points to create a zone'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      if (_drawingZoneType == 'no-go') {
        _noGoZones.add(List.from(_currentDrawingPoints));
      } else {
        _priorityZones.add(List.from(_currentDrawingPoints));
      }
      _currentDrawingPoints.clear();
      _isDrawingMode = false;
    });

    _updateMapElements();
  }

  void _cancelZoneDrawing() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentDrawingPoints.clear();
      _isDrawingMode = false;
    });
  }

  void _clearZones(String zoneType) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (zoneType == 'no-go') {
        _noGoZones.clear();
      } else if (zoneType == 'priority') {
        _priorityZones.clear();
      } else {
        _noGoZones.clear();
        _priorityZones.clear();
      }
    });
    _updateMapElements();
  }

  void _showEventDetails(Map<String, dynamic> event) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedEvent = event;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsSheetWidget(
        event: event,
        onClose: () {
          setState(() {
            _selectedEvent = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleManualDriveMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isManualDriveMode = !_isManualDriveMode;
    });
  }

  void _centerOnRobot() {
    HapticFeedback.lightImpact();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_robotLocation, 18),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: CustomAppBar(
            title: 'Map',
            subtitle:
                'Lat: ${_robotLocation.latitude.toStringAsFixed(6)}, Lng: ${_robotLocation.longitude.toStringAsFixed(6)}',
            variant: CustomAppBarVariant.withStatus,
            isConnected: true,
            actions: [
              IconButton(
                icon: CustomIconWidget(
                  iconName: _currentMapType == MapType.satellite
                      ? 'map'
                      : 'satellite',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: _toggleMapType,
                tooltip: 'Toggle map type',
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Google Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _robotLocation,
                zoom: 17,
              ),
              mapType: _currentMapType,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: _onMapTap,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

            // Drawing mode overlay
            if (_isDrawingMode && _currentDrawingPoints.isNotEmpty)
              IgnorePointer(
                child: CustomPaint(
                  painter: DrawingOverlayPainter(
                    points: _currentDrawingPoints,
                    color: _drawingZoneType == 'no-go'
                        ? Colors.red
                        : Colors.green,
                  ),
                  size: Size.infinite,
                ),
              ),

            // Top controls
            Positioned(
              top: 2.h,
              left: 4.w,
              right: 4.w,
              child: MapControlsWidget(
                isDrawingMode: _isDrawingMode,
                drawingZoneType: _drawingZoneType,
                onCenterRobot: _centerOnRobot,
                onToggleDrawing: _toggleDrawingMode,
              ),
            ),

            // Zone drawing controls
            if (_isDrawingMode)
              Positioned(
                bottom: 2.h,
                left: 4.w,
                right: 4.w,
                child: ZoneDrawingControlsWidget(
                  pointCount: _currentDrawingPoints.length,
                  zoneType: _drawingZoneType,
                  onComplete: _completeZoneDrawing,
                  onCancel: _cancelZoneDrawing,
                ),
              ),

            // Bottom toolbar (when not drawing)
            if (!_isDrawingMode)
              Positioned(
                bottom: 2.h,
                left: 4.w,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _clearZones('no-go'),
                              icon: CustomIconWidget(
                                iconName: 'delete',
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                              label: Text('Clear No-Go'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _clearZones('priority'),
                              icon: CustomIconWidget(
                                iconName: 'delete',
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                              label: Text('Clear Priority'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.all(1.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${_robotLocation.latitude.toStringAsFixed(6)}, ${_robotLocation.longitude.toStringAsFixed(6)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Manual drive mode indicator
            if (_isManualDriveMode)
              Positioned(
                top: 10.h,
                left: 4.w,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.all(1.5.h),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'warning',
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Manual Drive Mode Active',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: !_isDrawingMode
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'center_robot',
                  onPressed: _centerOnRobot,
                  backgroundColor: theme.colorScheme.primary,
                  child: CustomIconWidget(
                    iconName: 'my_location',
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                SizedBox(height: 1.h),
                FloatingActionButton(
                  heroTag: 'manual_drive',
                  onPressed: _toggleManualDriveMode,
                  backgroundColor: _isManualDriveMode
                      ? Colors.orange
                      : theme.colorScheme.secondary,
                  child: CustomIconWidget(
                    iconName: _isManualDriveMode ? 'stop' : 'gamepad',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

class DrawingOverlayPainter extends CustomPainter {
  final List<LatLng> points;
  final Color color;

  DrawingOverlayPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Note: This is a simplified visualization
    // In production, you'd need to convert LatLng to screen coordinates
    final path = Path();

    if (points.isNotEmpty) {
      path.moveTo(size.width * 0.5, size.height * 0.5);
      for (var point in points) {
        path.lineTo(
          size.width * 0.5 + (point.longitude * 1000),
          size.height * 0.5 + (point.latitude * 1000),
        );
      }
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(DrawingOverlayPainter oldDelegate) {
    return points != oldDelegate.points || color != oldDelegate.color;
  }
}
