import 'package:flutter/material.dart';

class SimpleCustomButton extends StatelessWidget {
  final Widget label;
  const SimpleCustomButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: height * 0.01,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.03,
              vertical: height * 0.01,
            ),
            child: label,
          ),
        ),
      ),
    );
  }
}
