import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSwitchTile extends StatelessWidget {
  // final Widget leading;
  final String leadingText;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchTile({
    super.key,
    // required this.leading,
    required this.leadingText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side
          Row(
            children: [
              // leading,
              Text(
                leadingText,
                style: TextStyle(
                  // fontSize: 16,
                  // color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),

          // Right side Switch
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }
}
