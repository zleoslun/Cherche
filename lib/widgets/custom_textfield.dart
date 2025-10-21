import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final int? maxLines;
  final Widget? suffix;
  final bool? enabled;
  const CustomTextField({
    super.key,
    required this.hint,
    this.maxLines,
    required this.controller,
    required this.textInputType,
    this.enabled = true,
    this.prefix,
    this.suffix,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // final double width = size.width;
    final double height = size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.007),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            keyboardType: widget.textInputType,
            controller: widget.controller,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            decoration: InputDecoration(
              prefixIcon: widget.prefix,
              suffixIcon: widget.suffix,
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
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
