import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

class BatteryIndicator extends StatefulWidget {
  final bool showPercentage;
  final bool showLabel;
  final double iconSize;

  const BatteryIndicator({
    super.key,
    this.showPercentage = true,
    this.showLabel = false,
    this.iconSize = 20,
  });

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;

  @override
  void initState() {
    super.initState();
    _loadBatteryInfo();
  }

  Future<void> _loadBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
          _batteryState = state;
        });
      }
    } catch (e) {
      debugPrint('Error loading battery info: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getBatteryColor(int level, BatteryState state) {
    if (state == BatteryState.charging) {
      return Colors.green;
    }
    if (level <= 20) {
      return Colors.red;
    }
    if (level <= 50) {
      return Colors.orange;
    }
    return Colors.green;
  }

  IconData _getBatteryIcon(int level, BatteryState state) {
    if (state == BatteryState.charging) {
      return Icons.battery_charging_full;
    }
    if (level >= 90) {
      return Icons.battery_full;
    }
    if (level >= 70) {
      return Icons.battery_6_bar;
    }
    if (level >= 50) {
      return Icons.battery_5_bar;
    }
    if (level >= 30) {
      return Icons.battery_3_bar;
    }
    if (level >= 15) {
      return Icons.battery_2_bar;
    }
    return Icons.battery_alert;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBatteryColor(_batteryLevel, _batteryState);
    final icon = _getBatteryIcon(_batteryLevel, _batteryState);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: widget.iconSize,
          color: color,
        ),
        if (widget.showPercentage) ...[
          const SizedBox(width: 4),
          Text(
            '$_batteryLevel%',
            style: TextStyle(
              fontSize: widget.iconSize - 4,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (widget.showLabel) ...[
          const SizedBox(width: 4),
          Text(
            _getBatteryLabel(_batteryLevel, _batteryState),
            style: TextStyle(
              fontSize: widget.iconSize - 4,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  String _getBatteryLabel(int level, BatteryState state) {
    if (state == BatteryState.charging) {
      return 'Cargando';
    }
    if (level <= 20) {
      return 'Batería baja';
    }
    if (level <= 50) {
      return 'Media';
    }
    return 'Alta';
  }
}