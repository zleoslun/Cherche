import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget label;
  final VoidCallback? onTap;
  final bool isLoading;
  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF130E6A),
          // gradient: const LinearGradient(
          //   colors: [Color(0xFF6972DA), Color(0xFF7354AF)],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
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
              // child: label,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   textAlign: TextAlign.center,
                  //   text,
                  //   style: TextStyle(color: Colors.black, fontSize: 16),
                  // ),
                  if (isLoading) ...[
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ] else ...[
                    label,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
