// TODO Implement this library.
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String filename;
  const UserAvatar({
    super.key,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: AssetImage("assets/images/$filename"),
    );
  }
}
