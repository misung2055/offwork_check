import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'DbHandle.dart';
import 'FixedValue.dart';

class SignPainter extends CustomPainter {

  List<List<Offset>> points;

  SignPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    //draw points on canvas
    points.forEach((element) {
      canvas.drawPoints(
          PointMode.polygon,
          element,
          Paint()
            ..color = Color(colorCasablanca)
            ..strokeWidth = 5);
    });
  }

  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

void showSignSheet(
    BuildContext context, int floor, Function(String) writeSign) {
  final List<List<Offset>> points = List.empty(growable: true);
  GlobalKey rePaintGlobalKey = GlobalKey();

  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => BottomSheet(
      backgroundColor: Colors.transparent,
      enableDrag: false,
      onClosing: () {},
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => Container(
            decoration: BoxDecoration(
              color: Color(colorBeeswax),
              border: Border.all(
                color: Color(colorBlush),
                width: 3,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            height: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "${floor + 2} 층 퇴근",
                    style: TextStyle(
                        fontSize: fixedFontSize, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(colorStormDust),
                        border: Border.all(
                          color: Color(colorMikado),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    width: 410,
                    height: 310,
                    child: GestureDetector(
                      onPanStart: (position) {
                        points.add(List<Offset>.empty(growable: true));
                      },
                      onPanUpdate: (position) {
                        Offset local = position.localPosition;
                        if (local.dx >= 5 &&
                            local.dy >= 5 &&
                            local.dx <= 400 &&
                            local.dy <= 300) {
                          points.last.add(position.localPosition);
                        }
                        setState(() {});
                      },
                      child: RepaintBoundary(
                        key: rePaintGlobalKey,
                        child: CustomPaint(
                          painter: SignPainter(points),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              RenderRepaintBoundary boundary = rePaintGlobalKey
                                  .currentContext!
                                  .findRenderObject() as RenderRepaintBoundary;
                              ui.Image image2 = await boundary.toImage();
                              ByteData? byteData = await image2.toByteData(
                                  format: ui.ImageByteFormat.png);
                              Uint8List pngBytes =
                                  byteData!.buffer.asUint8List();
                              writeSign(base64Encode(pngBytes));
                            } catch (err) {
                              print("이미지 저장 실패");
                            }
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.check),
                          label: Text(
                            "퇴근",
                            style: TextStyle(fontSize: fixedFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Color(colorPacificBlue),
                              minimumSize: Size(150, 60)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class FloorSignBar extends StatefulWidget {
  final Sign sign;

  const FloorSignBar({Key? key, required this.sign}) : super(key: key);

  @override
  _FloorSignBarState createState() => _FloorSignBarState();
}

class _FloorSignBarState extends State<FloorSignBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                "${widget.sign.floor + 2} 층",
                style: TextStyle(fontSize: 45),
                textAlign: TextAlign.center,
              ),
              Text(
                getDepartmentTitle(),
                style: TextStyle(
                    fontSize: fixedFontSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Color(colorMikado),
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Color(colorStormDust),
                  fixedSize:
                      Size.fromHeight(MediaQuery.of(context).size.height / 6)),
              child: widget.sign.sign.isEmpty
                  ? SizedBox()
                  : Image.memory(base64Decode(widget.sign.sign),
                      fit: BoxFit.fill),
              onPressed: () {
                showSignSheet(context, widget.sign.floor, (String bs64) async {
                  widget.sign.sign = bs64;
                  widget.sign.date = DateTime.now().toString();
                  widget.sign.workState = WorkState.offWork;
                  widget.sign.id = await dbHandler.insetDb(
                    dbTableList.sign,
                    widget.sign.toMap(),
                  );
                  setState(() {});
                });
              },
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.sign.workState == WorkState.offWork)
                Text(
                  getOffWorkString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fixedFontSize),
                ),
              if (widget.sign.workState == WorkState.work)
                Text(
                  "근무중",
                  style: TextStyle(
                      fontSize: fixedFontSize,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.sign.workState == WorkState.weekend)
                Text(
                  "주말",
                  style: TextStyle(
                      fontSize: fixedFontSize, fontWeight: FontWeight.bold),
                ),
              ElevatedButton(
                onPressed: widget.sign.workState != WorkState.work
                    ? () async {
                        widget.sign.workState = WorkState.work;
                        if (widget.sign.id != 0) {
                          await dbHandler.updateData(
                              dbTableList.sign, widget.sign);
                        }
                        widget.sign.sign = '';
                        widget.sign.date = '';
                        setState(() {});
                      }
                    : null,
                child: Text(
                  "출근",
                  style: TextStyle(fontSize: fixedFontSize),
                ),
                style:
                    ElevatedButton.styleFrom(primary: Color(colorPacificBlue)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getDepartmentTitle() {
    switch (widget.sign.floor) {
      case 0:
        return "관리부";
      case 1:
        return "진단사업본부";
      case 2:
        return "개발부";
      default:
        return "";
    }
  }

  String getOffWorkString() {
    if (widget.sign.date.isNotEmpty) {
      DateTime dateTime = DateTime.parse(widget.sign.date);
      return "퇴근\n" +
          "${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}";
    } else {
      return "";
    }
  }
}
