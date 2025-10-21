import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomContainer extends StatelessWidget {
  final String containerLable;
  final Widget column;
  const CustomContainer({
    super.key,
    required this.containerLable,
    required this.column,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 239, 239),
        boxShadow: [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //
          Text(
            containerLable,
            style: TextStyle(
              fontSize: (width < 550) ? 20 : 25,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          //
          column,
        ],
      ),
    );
  }
}
