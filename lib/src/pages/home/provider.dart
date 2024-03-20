import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_service/nearby_service.dart';

class HomeProvider extends ChangeNotifier {
  final _nearbyService = NearbyService.getInstance();
  bool isBrowser = false;
  bool _isNearbyServiceInitialized = false;
  bool _isDiscovering = false;

  List<NearbyDevice> _devices = [];

  List<NearbyDevice> get devices => _devices;

  StreamSubscription? _devicesListener;

  HomeProvider() {}

  Future<void> init() async {
    _nearbyService.communicationChannelState
        .addListener(() => notifyListeners());
    await _nearbyService.initialize();
    if (Platform.isAndroid) {
      final granted = await _nearbyService.android?.requestPermissions();
      if (granted ?? false) {
        // go to the checking Wi-fi step
        final isWifiEnabled = await _nearbyService.android?.checkWifiService();
        if (isWifiEnabled ?? false) {
          _isNearbyServiceInitialized = true;
        }
      }
    }

    if (Platform.isIOS) {
      _nearbyService.ios?.setIsBrowser(value: isBrowser);
      _isNearbyServiceInitialized = true;
    }
  }

  @override
  void dispose() {
    _devicesListener?.cancel();
    super.dispose();
  }

  _onDevicesDiscovered(List<NearbyDevice> list) {
    _devices = list;
    notifyListeners();
  }

  Future<void> discover() async {
    if (_isDiscovering || !_isNearbyServiceInitialized) {
      return;
    }
    _isDiscovering = true;
    try {
      _devicesListener?.cancel();
      final enable = await _nearbyService.discover();
      if (enable) {
        _devicesListener =
            _nearbyService.getPeersStream().listen(_onDevicesDiscovered);
      }
    } finally {
      _isDiscovering = false;
    }
  }
}
