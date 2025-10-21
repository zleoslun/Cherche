import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTextformfield extends StatefulWidget {
  final String hint;
  final String labelText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final bool obscureText;
  final bool enableToggle;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  const CustomTextformfield({
    super.key,
    required this.hint,
    required this.labelText,
    required this.controller,
    required this.textInputType,
    this.obscureText = false,
    this.enableToggle = false,
    this.prefix,
    this.suffix,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<CustomTextformfield> createState() => _CustomTextformfieldState();
}

class _CustomTextformfieldState extends State<CustomTextformfield> {
  late bool _obscureText;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final double width = size.width;
    final double height = size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.007),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.01),
            child: Text(
              widget.labelText,

              style: TextStyle(
                fontWeight: FontWeight.bold,
                // color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          TextFormField(
            keyboardType: widget.textInputType,
            controller: widget.controller,
            obscureText: _obscureText,
            maxLines: widget.maxLines,
            validator: widget.validator,
            decoration: InputDecoration(
              prefixIcon: widget.prefix,
              suffixIcon: widget.enableToggle
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // When the field is enabled but not focused.
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              // When the field is focused (active).
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              // When the field is disabled.
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              // When the field shows an error.
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              // When the field is both focused and has an error.
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              hintText: widget.hint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
