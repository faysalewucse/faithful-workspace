import 'package:flutter/material.dart';

class NamajTimeCard extends StatelessWidget {
  final String title;
  final String wakto;
  final String? jamat;
  final double height;
  final Color color;
  final double textSize;

  const NamajTimeCard(
      {super.key,
      required this.title,
      required this.wakto,
      required this.height,
      required this.color,
      required this.textSize,
      required this.jamat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.blue[100]!, blurRadius: 3)]),
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(title,
                style: TextStyle(
                    fontSize: textSize, color: Theme.of(context).primaryColor)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(wakto,
                    style: TextStyle(
                        fontSize: textSize,
                        color: Theme.of(context).primaryColor)),
                Row(
                  children: [
                    Text(
                      jamat!,
                      style: TextStyle(
                          fontSize: textSize,
                          color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.notifications,
                      color: Colors.black12,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
