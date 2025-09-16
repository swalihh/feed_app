import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool get isConnected => _connectionStatus != ConnectivityResult.none;
  bool get isWifi => _connectionStatus == ConnectivityResult.wifi;
  bool get isMobile => _connectionStatus == ConnectivityResult.mobile;
  bool get isEthernet => _connectionStatus == ConnectivityResult.ethernet;

  ConnectivityResult get connectionStatus => _connectionStatus;

  Future<void> initialize() async {
    // Get initial connectivity status
    final List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity();
    _connectionStatus = connectivityResults.isNotEmpty
        ? connectivityResults.first
        : ConnectivityResult.none;

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResults) {
    final ConnectivityResult newStatus = connectivityResults.isNotEmpty
        ? connectivityResults.first
        : ConnectivityResult.none;

    if (_connectionStatus != newStatus) {
      _connectionStatus = newStatus;
      notifyListeners();

      // Log connectivity changes
      if (kDebugMode) {
        print('Connectivity changed: ${_getConnectionName(newStatus)}');
      }
    }
  }

  String _getConnectionName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
      default:
        return 'No Connection';
    }
  }

  String get connectionName => _getConnectionName(_connectionStatus);

  Future<bool> hasInternetConnection() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.isNotEmpty &&
           connectivityResults.first != ConnectivityResult.none;
  }

  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Callback for when connection is restored
  final List<VoidCallback> _onReconnectedCallbacks = [];

  void addOnReconnectedCallback(VoidCallback callback) {
    _onReconnectedCallbacks.add(callback);
  }

  void removeOnReconnectedCallback(VoidCallback callback) {
    _onReconnectedCallbacks.remove(callback);
  }

  void _notifyReconnected() {
    for (final callback in _onReconnectedCallbacks) {
      callback();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }
}