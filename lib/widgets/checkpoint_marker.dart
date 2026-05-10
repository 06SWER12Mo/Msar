import 'package:flutter/material.dart';
import '../models/checkpoint.dart';
import '../models/checkpoint_status.dart';
import '../utils/constants.dart';

class CheckpointMarker extends StatelessWidget {
  final Checkpoint checkpoint;
  final CheckpointStatus? status;
  final VoidCallback onTap;

  const CheckpointMarker({
    Key? key,
    required this.checkpoint,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entranceColor =
        _statusColor(status?.entrance.status ?? 'OPEN');
    final exitColor =
        _statusColor(status?.exit.status ?? 'OPEN');

    final pinColor = _worstColor(
        status?.entrance.status ?? 'OPEN', status?.exit.status ?? 'OPEN');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name label with dual-dot indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(entranceColor),
                const SizedBox(width: 3),
                _dot(exitColor),
                const SizedBox(width: 5),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: Text(
                      checkpoint.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Triangle pointer
          CustomPaint(
            size: const Size(12, 6),
            painter: _TrianglePainter(Colors.white),
          ),
          // Pin icon
          Icon(
            Icons.location_on,
            color: pinColor,
            size: 28,
            shadows: const [
              Shadow(
                  color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'OPEN': return const Color(AppConstants.openColor);
      case 'CROWDED': return const Color(AppConstants.crowdedColor);
      case 'CLOSED': return const Color(AppConstants.closedColor);
      default: return const Color(AppConstants.openColor);
    }
  }

  Color _worstColor(String a, String b) {
    int priority(String s) => AppConstants.statusPriority[s] ?? 0;
    return _statusColor(priority(a) >= priority(b) ? a : b);
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}