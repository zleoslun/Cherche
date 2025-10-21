import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTile extends StatelessWidget {
  // final Widget? leading;
  final String leadingText;

  final VoidCallback ontap;
  const CustomTile({
    super.key,
    // this.leading,
    required this.leadingText,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: ontap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //
            Row(
              children: [
                // leading!,
                Text(
                  leadingText,
                  style: TextStyle(
                    // fontSize: 16,
                    // color: themeProvider.isDarkMode
                    //     ? Colors.white
                    //     : Colors.black,
                  ),
                ),
              ],
            ),

            //
            Icon(Icons.arrow_forward_ios, size: 15),
          ],
        ),
      ),
    );
  }
}
