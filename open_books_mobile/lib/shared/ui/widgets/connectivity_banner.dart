import 'dart:async';

import 'package:flutter/material.dart';

import 'package:open_books_mobile/shared/services/network_info.dart';

class ConnectivityBanner extends StatefulWidget {
  final NetworkInfo networkInfo;
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.networkInfo,
    required this.child,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  StreamSubscription<bool>? _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = widget.networkInfo.onConnectivityChanged.listen((connected) {
      setState(() {
        _isConnected = connected;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final connected = await widget.networkInfo.isConnected;
    if (mounted) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isConnected)
          MaterialBanner(
            content: const Text(
              'Sin conexion. Tus avances se guardaran localmente y se sincronizaran cuando te conectes.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            leading: const Icon(Icons.cloud_off, color: Colors.white),
            actions: [
              TextButton(
                onPressed: _checkConnectivity,
                child: const Text(
                  'REINTENTAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class SyncStatusToast {
  static void showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Progreso sincronizado exitosamente'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message.isNotEmpty 
                  ? 'Fallo la sincronizacion: $message'
                  : 'Fallo la sincronizacion. Por favor, revisa tu conexion.'),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'REINTENTAR',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 8),
            Text('Sin conexion - guardado localmente'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}