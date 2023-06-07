import 'package:flutter/material.dart';

class Question extends StatelessWidget {
  var question;

  Question(this.question);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.all(10),
      child: Text(question, style: TextStyle(fontSize: 28)),
    );
  }
}
