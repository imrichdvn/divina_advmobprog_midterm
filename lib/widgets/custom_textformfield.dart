import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.validator,
    required this.onSaved,
    this.controller,
    this.isObscure = false,
    required this.fontSize,
    required this.fontColor,
    this.hintTextSize = 12,
    this.hintText = '',
    this.fillColor = Colors.black12,
    required this.height,
    required this.width,
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
    this.suffixIcon,
  });

  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextEditingController? controller;
  final bool isObscure;
  final double fontSize;
  final Color? fontColor;
  final double height, width;
  final double hintTextSize;
  final String hintText;
  final Color fillColor;
  final TextInputType keyboardType;
  final int maxLength;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      onSaved: onSaved,
      controller: controller ?? TextEditingController(),
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      style: TextStyle(
        fontFamily: 'Frutiger',
        fontSize: fontSize,
        color: fontColor ?? FB_DARK_PRIMARY,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(width, height, width, height),
        focusColor: Colors.black12,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: FB_DARK_PRIMARY, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        errorStyle: const TextStyle(fontFamily: 'Frutiger'),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: FB_LIGHT_PRIMARY, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        filled: true,
        hintStyle: TextStyle(
          color: Colors.black26,
          fontSize: hintTextSize,
          fontFamily: 'Frutiger',
        ),
        hintText: hintText,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
