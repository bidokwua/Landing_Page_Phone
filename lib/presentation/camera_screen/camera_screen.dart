import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/control_bar_widget.dart';
import './widgets/emergency_checklist_widget.dart';
import './widgets/telemetry_overlay_widget.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isInspectMode = false;
  bool _isEmergencyMode = false;
  XFile? _capturedImage;
  String _recordingDuration = "00:00";
  int _recordingSeconds = 0;
  double _currentZoom = 1.0;
  final double _minZoom = 1.0;
  final double _maxZoom = 4.0;

  late TabController _tabController;
  final int _currentTabIndex = 2; // Camera tab active

  // Mock telemetry data
  final Map<String, dynamic> _telemetryData = {
    "battery": 87,
    "connectionStrength": 4,
    "temperature": 72.5,
    "smokeIndex": 12,
    "status": "Active",
    "lastUpdate": DateTime.now(),
  };

  // Emergency checklist steps
  final List<Map<String, dynamic>> _emergencySteps = [
    {
      "step": 1,
      "title": "Verify Robot Position",
      "description": "Confirm robot is at home base",
      "status": "completed",
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
    },
    {
      "step": 2,
      "title": "Check Suppression Systems",
      "description": "Water tank: 95%, Powder: 88%",
      "status": "completed",
      "timestamp": DateTime.now().subtract(Duration(minutes: 3)),
    },
    {
      "step": 3,
      "title": "Perimeter Scan",
      "description": "Scanning property boundaries",
      "status": "in_progress",
      "timestamp": DateTime.now().subtract(Duration(minutes: 1)),
    },
    {
      "step": 4,
      "title": "Deploy Defense Position",
      "description": "Moving to priority zone",
      "status": "pending",
      "timestamp": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _handleTabChange(_tabController.index);
      }
    });
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        setState(() => _isCameraInitialized = false);
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _isCameraInitialized = false);
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      // Settings not supported on this platform
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      final XFile photo = await _cameraController!.takePicture();
      setState(() => _capturedImage = photo);

      // Show thumbnail preview
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo captured successfully'),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _showGalleryView(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to capture photo')));
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_isRecording) {
        await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
          _recordingDuration = "00:00";
        });
        HapticFeedback.mediumImpact();
      } else {
        await _cameraController!.startVideoRecording();
        setState(() => _isRecording = true);
        HapticFeedback.mediumImpact();
        _startRecordingTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Recording operation failed')));
      }
    }
  }

  void _startRecordingTimer() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (!_isRecording) return false;

      setState(() {
        _recordingSeconds++;
        final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
        final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
        _recordingDuration = "$minutes:$seconds";
      });
      return true;
    });
  }

  void _toggleInspectMode() {
    HapticFeedback.lightImpact();
    setState(() => _isInspectMode = !_isInspectMode);
  }

  void _toggleEmergencyMode() {
    HapticFeedback.heavyImpact();
    setState(() => _isEmergencyMode = !_isEmergencyMode);
    if (_isEmergencyMode) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _showGalleryView() {
    if (_capturedImage == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              kIsWeb
                  ? Image.network(_capturedImage!.path)
                  : Image.file(File(_capturedImage!.path)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text('Close'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Share functionality would go here
                      Navigator.pop(context);
                    },
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTabChange(int index) {
    HapticFeedback.lightImpact();
    final routes = [
      '/home-dashboard',
      '/map-screen',
      '/camera-screen',
      '/settings-screen',
    ];

    if (index != _currentTabIndex && index < routes.length) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(routes[index]);
    }
  }

  void _placeWaypoint(Offset position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Place Waypoint'),
        content: Text('Set inspection waypoint at this location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Waypoint placed successfully')),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _isEmergencyMode ? 'Emergency Mode' : 'Live Camera',
        subtitle: _isEmergencyMode ? 'Defending Property' : 'Robot Feed',
        variant: _isEmergencyMode
            ? CustomAppBarVariant.emergency
            : CustomAppBarVariant.withStatus,
        isConnected: true,
        isEmergencyMode: _isEmergencyMode,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isEmergencyMode ? 'emergency_off' : 'emergency',
              color: _isEmergencyMode ? Colors.white : theme.colorScheme.error,
              size: 24,
            ),
            onPressed: _toggleEmergencyMode,
            tooltip: _isEmergencyMode
                ? 'Exit Emergency Mode'
                : 'Enter Emergency Mode',
          ),
        ],
      ),
      body: SafeArea(
        child: _isEmergencyMode ? _buildEmergencyView() : _buildNormalView(),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: CustomBottomBar(
          currentIndex: _currentTabIndex,
          onTap: _handleTabChange,
        ),
      ),
    );
  }

  Widget _buildNormalView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      child: Column(
        children: [
          Expanded(child: _buildCameraPreview()),
          SizedBox(height: 2.h),
          ControlBarWidget(
            isRecording: _isRecording,
            isInspectMode: _isInspectMode,
            recordingDuration: _recordingDuration,
            onCapturePhoto: _capturePhoto,
            onToggleRecording: _toggleRecording,
            onToggleInspectMode: _toggleInspectMode,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      child: Column(
        children: [
          Expanded(flex: 3, child: _buildCameraPreview()),
          SizedBox(height: 2.h),
          Expanded(
            flex: 2,
            child: EmergencyChecklistWidget(
              steps: _emergencySteps,
              currentStatus: _telemetryData["status"] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final theme = Theme.of(context);

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'videocam_off',
                color: theme.colorScheme.onSurfaceVariant,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text('No Signal', style: theme.textTheme.titleLarge),
              SizedBox(height: 1.h),
              Text(
                'Attempting to reconnect...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: () {
        setState(() => _currentZoom = _minZoom);
      },
      onScaleUpdate: (details) {
        if (!kIsWeb) {
          final newZoom = (_currentZoom * details.scale).clamp(
            _minZoom,
            _maxZoom,
          );
          _cameraController?.setZoomLevel(newZoom);
          setState(() => _currentZoom = newZoom);
        }
      },
      onTapUp: _isInspectMode
          ? (details) => _placeWaypoint(details.localPosition)
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CameraPreview(_cameraController!),
              ),
              TelemetryOverlayWidget(
                telemetryData: _telemetryData,
                isInspectMode: _isInspectMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
