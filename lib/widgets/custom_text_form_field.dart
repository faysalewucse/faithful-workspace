import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;

  const CustomTextFormField(
      {super.key,
      required this.textEditingController,
      required this.labelText,
      required this.hintText,
      this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    var PRIMARY_COLOR = Theme.of(context).primaryColor;

    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
        isDense: true,
        hintText: hintText,
        hintStyle: TextStyle(color: PRIMARY_COLOR),
        labelStyle: TextStyle(color: PRIMARY_COLOR),
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
          size: 25,
          color: PRIMARY_COLOR,
        ),
        suffixIcon: const Icon(Icons.visibility),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PRIMARY_COLOR),
        ),
      ),
    );
  }
}
