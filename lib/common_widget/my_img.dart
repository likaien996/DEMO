import 'package:flutter/material.dart';

class MyImgWidget extends StatelessWidget {
  final String? url;

  const MyImgWidget({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    final temp = url;
    if (temp == null || temp.isEmpty) {
      return const SizedBox();
    }
    if (temp.startsWith("http")) {
      return Image.network(temp,fit: BoxFit.cover,);
    }
    return Image.asset(temp,fit: BoxFit.cover,);
  }
}
