import 'dart:convert';
import 'package:flutter/material.dart';

import 'DbHandle.dart';
import 'FixedValue.dart';

class OffWorkList extends StatefulWidget {
  const OffWorkList({Key? key}) : super(key: key);

  @override
  _OffWorkListState createState() => _OffWorkListState();
}

class _OffWorkListState extends State<OffWorkList> {
  List<Sign> signs = List.empty();
  DateTime selectDate = DateTime.now();

  @override
  void initState() {
    dbHandler.readDb(dbTableList.sign).then((list) {
      setState(() {
        signs = list.map((e) => e as Sign).toList().reversed.toList();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Color(colorAqua),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 10),
              child: ElevatedButton.icon(
                onPressed: () async {
                  showDatePicker(
                    initialDate: selectDate,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2050),
                    context: context,
                  ).then((date) async {
                    try {
                      if (date != null) {
                        selectDate = date;
                        String searchStr = date.toString().split(' ').first;
                        dbHandler
                            .readDb(DbTableList().sign, searchStr: searchStr)
                            .then((list) {
                          setState(() {
                            signs = list
                                .map((e) => e as Sign)
                                .toList()
                                .reversed
                                .toList();
                          });
                        });
                      }
                    } catch (err) {}
                  });
                },
                icon: Icon(Icons.calendar_today_outlined),
                label: Text(
                  "날짜 선택",
                  style: TextStyle(fontSize: fixedFontSize),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Color(colorPacificBlue),
                    minimumSize: Size(150, 60)),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(colorBeeswax),
                  border: Border.all(
                    color: Color(colorMikado),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: ListView.builder(
                  itemCount: signs.length,
                  itemBuilder: (context, index) {
                    final String date = signs[index].date;
                    final DateTime dateTime = DateTime.parse(date);
                    return Dismissible(
                      key: Key(date),
                      child: Container(
                        height: 100,
                        margin: EdgeInsets.only(top: 2, bottom: 2),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: fixedFontSize),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${dateTime.hour}시 ${dateTime.minute}분",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: fixedFontSize),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${signs[index].floor + 2} 층",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: fixedFontSize),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(colorStormDust),
                                border: Border.all(
                                  color: Color(colorMikado),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Image.memory(
                                  base64Decode(
                                    signs[index].sign,
                                  ),
                                  fit: BoxFit.fill),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        dbHandler.deleteData(dbTableList.sign, signs[index].id);
                      },
                      direction: DismissDirection.endToStart,
                      background: Container(
                          padding: EdgeInsets.only(right: 50),
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.delete),
                          color: Colors.red),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//
// return Container(
// child: Center(
// child: TextButton(
// child: Text("aa"),
// onPressed: () async {
// List sings = await dbHandler.readDb(dbTableList.sign);
// },
// ),
// ),
// );
