import 'package:faithful_workspace/constant/Constant.dart';
import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomPrimaryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var MAX_WIDTH = MediaQuery.of(context).size.width;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR,),
      onPressed: onPressed,
      child: Container(
          color: PRIMARY_COLOR,
          padding: const EdgeInsets.all(15),
          width: MAX_WIDTH,
          child: const Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
    );
  }
}
