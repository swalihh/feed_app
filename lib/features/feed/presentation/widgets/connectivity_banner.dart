import 'package:flutter/material.dart';
import '../../../../core/consts/color_manager.dart';
import '../../../../core/services/connectivity_service.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _showBanner = false;
  bool _wasConnected = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _connectivityService.addListener(_onConnectivityChanged);
    _checkInitialConnection();
  }

  void _checkInitialConnection() {
    final isConnected = _connectivityService.isConnected;
    _wasConnected = isConnected;
    if (!isConnected) {
      _showNoConnectionBanner();
    }
  }

  void _onConnectivityChanged() {
    final isConnected = _connectivityService.isConnected;

    if (!isConnected && _wasConnected) {
      _showNoConnectionBanner();
    } else if (isConnected && !_wasConnected) {
      _showReconnectedBanner();
    }

    _wasConnected = isConnected;
  }

  void _showNoConnectionBanner() {
    if (!mounted) return;
    setState(() {
      _showBanner = true;
    });
    _animationController.forward();
  }

  void _showReconnectedBanner() {
    if (!mounted) return;
    setState(() {
      _showBanner = true;
    });
    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideBanner();
      }
    });
  }

  void _hideBanner() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showBanner = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 100),
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _connectivityService.isConnected
                              ? [
                                  ColorManager.success,
                                  ColorManager.success.withOpacity(0.8),
                                ]
                              : [
                                  ColorManager.warning,
                                  ColorManager.warning.withOpacity(0.8),
                                ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (_connectivityService.isConnected
                                    ? ColorManager.success
                                    : ColorManager.warning)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorManager.textPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                _connectivityService.isConnected
                                    ? Icons.wifi_rounded
                                    : Icons.wifi_off_rounded,
                                color: ColorManager.textPrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _connectivityService.isConnected
                                        ? 'Back Online'
                                        : 'No Internet Connection',
                                    style: TextStyle(
                                      color: ColorManager.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  if (_connectivityService.isConnected) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Connected via ${_connectivityService.connectionName}',
                                      style: TextStyle(
                                        color: ColorManager.textPrimary.withOpacity(0.8),
                                        fontSize: 12,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Some features may be limited',
                                      style: TextStyle(
                                        color: ColorManager.textPrimary.withOpacity(0.8),
                                        fontSize: 12,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (!_connectivityService.isConnected)
                              GestureDetector(
                                onTap: _hideBanner,
                                child: Icon(
                                  Icons.close_rounded,
                                  color: ColorManager.textPrimary,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}