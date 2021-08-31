import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DbHandle.dart';
import 'FixedValue.dart';
import 'OffWorkBar.dart';

class OffWork extends StatefulWidget {
  const OffWork({Key? key}) : super(key: key);

  @override
  _OffWorkState createState() => _OffWorkState();
}

final List<Sign> offWorkSingList = [
  Sign(sign: '', date: '', floor: 0),
  Sign(sign: '', date: '', floor: 1),
  Sign(sign: '', date: '', floor: 2)
];

class _OffWorkState extends State<OffWork> {
  late Timer dayCheckTimer;
  late Timer workCheckTimer;
  late DateTime today;

  @override
  void initState() {
    startDayCheckTimer();
    initOffWorkList();
    startWorkCheckTimer();
    initFloorSign();
    super.initState();
  }

  void initFloorSign() async {
    List<bool> findSigns =
        List.generate(offWorkSingList.length, (index) => false);

    //work 시간 초기화는 는 9시를 기준으로함
    if (today.hour < 9) {
      //없다면 오늘 검색
      String searchStr = today.toString().split(' ').first;
      List list =
          await dbHandler.readDb(dbTableList.sign, searchStr: searchStr);
      List<Sign> tempSings =
          list.map((e) => e as Sign).toList().reversed.toList();
      tempSings.forEach((sign) {
        if (!findSigns[sign.floor] && DateTime.parse(sign.date).hour < 9) {
          if (sign.workState == WorkState.offWork) {
            offWorkSingList[sign.floor] = sign;
          }
          findSigns[sign.floor] = true;
        }
      });

      //이전날 9시 이후부터 검색
      searchStr = today.subtract(Duration(days: 1)).toString().split(' ').first;
      list = await dbHandler.readDb(dbTableList.sign, searchStr: searchStr);
      tempSings = list.map((e) => e as Sign).toList().reversed.toList();
      tempSings.forEach((sign) {
        if (!findSigns[sign.floor] && DateTime.parse(sign.date).hour >= 9) {
          if (sign.workState == WorkState.offWork) {
            offWorkSingList[sign.floor] = sign;
          }
          findSigns[sign.floor] = true;
        }
      });
    } else {
      //다음날 9시까지는 검색
      String searchStr =
          today.add(Duration(days: 1)).toString().split(' ').first;
      List list =
          await dbHandler.readDb(dbTableList.sign, searchStr: searchStr);
      List<Sign> tempSings =
          list.map((e) => e as Sign).toList().reversed.toList();
      tempSings.forEach((sign) {
        if (!findSigns[sign.floor] && DateTime.parse(sign.date).hour < 9) {
          if (sign.workState == WorkState.offWork) {
            offWorkSingList[sign.floor] = sign;
          }
          findSigns[sign.floor] = true;
        }
      });

      searchStr = today.toString().split(' ').first;
      list = await dbHandler.readDb(dbTableList.sign, searchStr: searchStr);
      tempSings = list.map((e) => e as Sign).toList().reversed.toList();
      tempSings.forEach((sign) {
        if (!findSigns[sign.floor]) {
          if (sign.workState == WorkState.offWork &&
              DateTime.parse(sign.date).hour >= 9) {
            offWorkSingList[sign.floor] = sign;
          }
          findSigns[sign.floor] = true;
        }
      });
    }

    checkSetState();
  }

  int getTimeDiffFromTomorrow({int addHour = 0, int addDay = 1}) {
    today = DateTime.now();
    DateTime tomorrow = today.add(Duration(days: addDay));
    DateTime addHourTime =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, addHour);
    Duration diffDuration = addHourTime.difference(today);
    return diffDuration.inSeconds;
  }

  void startDayCheckTimer() {
    int waitSecond = getTimeDiffFromTomorrow();
    print("startDayCheckTimer: ${Duration(seconds: waitSecond).toString()}");
    dayCheckTimer = Timer(Duration(seconds: waitSecond + 1), () {
      today = DateTime.now();
      checkSetState();
      startDayCheckTimer();
    });
  }

  void startWorkCheckTimer() {
    today = DateTime.now();
    late int waitSecond;
    if (today.hour < 9) {
      waitSecond = getTimeDiffFromTomorrow(addHour: 9, addDay: 0);
    } else {
      waitSecond = getTimeDiffFromTomorrow(addHour: 9);
    }
    print("startWorkCheckTimer: ${Duration(seconds: waitSecond).toString()}");
    workCheckTimer = Timer(Duration(seconds: waitSecond + 1), () {
      initOffWorkList();
      checkSetState();
      startWorkCheckTimer();
    });
  }

  @override
  void dispose() {
    dayCheckTimer.cancel();
    workCheckTimer.cancel();
    super.dispose();
  }

  void checkSetState() {
    if (this.mounted) {
      setState(() {});
    }
  }

  void initOffWorkList() {
    if (today.weekday == DateTime.sunday ||
        today.weekday == DateTime.saturday) {
      offWorkSingList.forEach((element) {
        element.date = "";
        element.sign = "";
        element.workState = WorkState.weekend;
      });
    } else {
      offWorkSingList.forEach((element) {
        element.date = "";
        element.sign = "";
        element.workState = WorkState.work;
      });
    }
  }

  String getWeekName(int day) {
    String name = "";
    switch (day) {
      case 1:
        name = "월요일";
        break;
      case 2:
        name = "화요일";
        break;
      case 3:
        name = "수요일";
        break;
      case 4:
        name = "목요일";
        break;
      case 5:
        name = "금요일";
        break;
      case 6:
        name = "토요일";
        break;
      case 7:
        name = "일요일";
        break;
      default:
        break;
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(colorAqua),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Text(
              "${today.year}년 ${today.month}월 ${today.day}일 ${getWeekName(today.weekday)}",
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(colorBeeswax),
                border: Border.all(
                  color: Color(colorMikado),
                  width: 4,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  FloorSignBar(sign: offWorkSingList[0]),
                  Spacer(),
                  Divider(
                    color: Color(colorMikado),
                    thickness: 2,
                  ),
                  Spacer(),
                  FloorSignBar(sign: offWorkSingList[1]),
                  Spacer(),
                  Divider(
                    color: Color(colorMikado),
                    thickness: 2,
                  ),
                  Spacer(),
                  FloorSignBar(sign: offWorkSingList[2]),
                  Spacer(),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(20.0),
                  //   child: Image.network(
                  //     "https://media4.giphy.com/media/xT0xezQGU5xCDJuCPe/giphy.gif?cid=790b76116bd56c2e902a257478990e91e0895b8be3ecc012&rid=giphy.gif&ct=g",
                  //     fit: BoxFit.fill,
                  //     height: 300.0,
                  //     width: 300.0,
                  //   ),
                  // ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: SizedBox(
                  //         child: TextField(
                  //           decoration: new InputDecoration(
                  //             focusedBorder: OutlineInputBorder(
                  //               borderSide:
                  //               BorderSide(color: Color(colorPacificBlue), width: 4.0),
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderSide:
                  //               BorderSide(color: Color(colorPeachy), width: 4.0),
                  //             ),
                  //             hintText: '이름',
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     ElevatedButton.icon(
                  //       onPressed: () {
                  //
                  //       },
                  //       icon: Icon(Icons.person_search),
                  //       label: Text(
                  //         "선택",
                  //         style: TextStyle(fontSize: fixedFontSize),
                  //       ),
                  //       style: ElevatedButton.styleFrom(
                  //           primary: Color(colorPacificBlue),
                  //           minimumSize: Size(150, 60)),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Text(
              "* 평일 휴무일에는 출근자가 없어도 근무중으로 표시되니 유의바랍니다.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
