import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';


class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final String? label;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final bool enableInteractiveSelection;
  final GestureTapCallback? onTap;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final int maxLines;
  final EdgeInsetsGeometry margin;
  final bool autofocus;
  final TextStyle? style;

  const AppTextField({
    Key? key,
    this.controller,
    this.keyboardType,
    this.label,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.enableInteractiveSelection = true,
    this.enabledBorder,
    this.focusedBorder,
    this.focusedErrorBorder,
    this.errorBorder,
    this.maxLines = 1,
    this.margin = const EdgeInsets.only(top: 8, bottom: 8, right: 20),
    this.autofocus = false,
    this.onChanged,
    this.hintText,
    this.suffixIcon,
    this.textInputAction,
    this.width,
    this.padding,
    this.height,
    this.prefixIcon,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.textTheme.headline4!.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
          ),
        ],
      ),
      padding: padding,
      width: width,
      height: height,
      child: TextFormField(
        style: style,
        cursorHeight: 25,
        textInputAction: textInputAction,
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        autofocus: false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: false,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          isDense: true,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.hintText,
              fontWeight: FontWeight.w400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
