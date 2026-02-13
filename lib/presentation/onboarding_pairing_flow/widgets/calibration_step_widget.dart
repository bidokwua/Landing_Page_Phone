import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CalibrationStepWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onCalibrationComplete;

  const CalibrationStepWidget({super.key, required this.onCalibrationComplete});

  @override
  State<CalibrationStepWidget> createState() => _CalibrationStepWidgetState();
}

class _CalibrationStepWidgetState extends State<CalibrationStepWidget> {
  GoogleMapController? _mapController;
  LatLng _homeBaseLocation = LatLng(37.7749, -122.4194);
  final Set<Polygon> _propertyBoundary = {};
  final List<LatLng> _boundaryPoints = [];
  bool _isDrawingMode = false;
  MapType _mapType = MapType.satellite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calibrate Home Base',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Set your robot\'s home base location and define property boundaries',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildMapControls(theme),
                  SizedBox(height: 2.h),
                  _buildMap(theme),
                  SizedBox(height: 2.h),
                  _buildInstructions(theme),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _boundaryPoints.length >= 3
                  ? _completeCalibration
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.colorScheme.surface,
                disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Complete Calibration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Map Type',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SegmentedButton<MapType>(
                  segments: [
                    ButtonSegment(
                      value: MapType.satellite,
                      label: Text('Satellite'),
                    ),
                    ButtonSegment(
                      value: MapType.normal,
                      label: Text('Standard'),
                    ),
                  ],
                  selected: {_mapType},
                  onSelectionChanged: (Set<MapType> newSelection) {
                    setState(() {
                      _mapType = newSelection.first;
                    });
                  },
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          decoration: BoxDecoration(
            color: _isDrawingMode
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isDrawingMode
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
          child: IconButton(
            icon: CustomIconWidget(
              iconName: 'edit',
              color: _isDrawingMode
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isDrawingMode = !_isDrawingMode;
                if (!_isDrawingMode && _boundaryPoints.isNotEmpty) {
                  _updatePropertyBoundary();
                }
              });
            },
            tooltip: _isDrawingMode ? 'Stop Drawing' : 'Draw Boundary',
          ),
        ),
        if (_boundaryPoints.isNotEmpty) ...[
          SizedBox(width: 2.w),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: IconButton(
              icon: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _boundaryPoints.clear();
                  _propertyBoundary.clear();
                });
              },
              tooltip: 'Clear Boundary',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMap(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _homeBaseLocation,
            zoom: 18,
          ),
          mapType: _mapType,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: _isDrawingMode ? _addBoundaryPoint : null,
          markers: {
            Marker(
              markerId: MarkerId('home_base'),
              position: _homeBaseLocation,
              draggable: true,
              onDragEnd: (newPosition) {
                setState(() {
                  _homeBaseLocation = newPosition;
                });
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: 'Home Base',
                snippet: 'Drag to reposition',
              ),
            ),
          },
          polygons: _propertyBoundary,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Calibration Instructions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _buildInstructionItem(
            theme,
            '1',
            'Drag the red marker to set your robot\'s home base location',
          ),
          _buildInstructionItem(
            theme,
            '2',
            'Tap the edit button to enable boundary drawing mode',
          ),
          _buildInstructionItem(
            theme,
            '3',
            'Tap on the map to create boundary points (minimum 3 points)',
          ),
          _buildInstructionItem(
            theme,
            '4',
            'The boundary will automatically close when you stop drawing',
          ),
          if (_boundaryPoints.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                'Boundary points: ${_boundaryPoints.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(ThemeData theme, String number, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  void _addBoundaryPoint(LatLng point) {
    setState(() {
      _boundaryPoints.add(point);
      if (_boundaryPoints.length >= 3) {
        _updatePropertyBoundary();
      }
    });
  }

  void _updatePropertyBoundary() {
    setState(() {
      _propertyBoundary.clear();
      _propertyBoundary.add(
        Polygon(
          polygonId: PolygonId('property_boundary'),
          points: _boundaryPoints,
          strokeColor: Colors.blue,
          strokeWidth: 3,
          fillColor: Colors.blue.withValues(alpha: 0.2),
        ),
      );
    });
  }

  void _completeCalibration() {
    final calibrationData = {
      'homeBase': {
        'latitude': _homeBaseLocation.latitude,
        'longitude': _homeBaseLocation.longitude,
      },
      'propertyBoundary': _boundaryPoints
          .map(
            (point) => {
              'latitude': point.latitude,
              'longitude': point.longitude,
            },
          )
          .toList(),
    };
    widget.onCalibrationComplete(calibrationData);
  }
}
