import 'package:flutter/material.dart';
import 'ongoing.dart';

class ClickableTextBlock extends StatefulWidget {
  final String lineNum;
  final String id;

  const ClickableTextBlock({Key? key, required this.lineNum, required this.id})
      : super(key: key);

  @override
  _ClickableTextBlockState createState() => _ClickableTextBlockState();
}

class _ClickableTextBlockState extends State<ClickableTextBlock> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OnGoing(lineNum: widget.lineNum, id: widget.id)),
        );
        print("Tapped on container");
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all()),
        // alignment: Alignment.center,
        child: Text(
          //Alignment: Alignment.center,
          widget.lineNum,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        // constraints: BoxConstraints.expand(),
      ),
    );
  }
}
