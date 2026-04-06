import 'package:flutter/material.dart';

class FloorPlanWidget extends StatelessWidget {
  final ({double x, double y})? position;
  final void Function(double x, double y)? onTap;
  final Color dotColor;

  FloorPlanWidget({
    this.position,
    this.onTap,
    this.dotColor = Colors.lightBlueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTapDown: onTap != null
            ? (details) =>
                  onTap!(details.localPosition.dx, details.localPosition.dy)
            : null,
        child: Stack(
          children: [
            Image.asset('assets/planimetria_casa.jpg'),
            if (position != null)
              Positioned(
                left: position!.x - 7.5,
                top: position!.y - 7.5,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
