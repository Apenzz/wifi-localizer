import 'package:flutter/material.dart';

class FloorPlanWidget extends StatelessWidget {
  final ({double x, double y})? position;
  final List<({double x, double y})> trainingPoints;
  final void Function(double x, double y)? onTap;
  final Color dotColor;

  FloorPlanWidget({
    this.position,
    this.trainingPoints = const [],
    this.onTap,
    this.dotColor = Colors.lightBlueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ]
      ),
      child: GestureDetector(
        onTapDown: onTap != null
            ? (details) =>
                  onTap!(details.localPosition.dx, details.localPosition.dy)
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset('assets/torre_archimede_piano1.jpg'),
              ...trainingPoints.map((point) => Positioned(
                left: point.x - 5,
                top: point.y - 5,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              )),
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
      ),
    );
  }
}
