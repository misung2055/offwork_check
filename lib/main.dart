import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'FixedValue.dart';
import 'OffWork.dart';
import 'OffWorkList.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          colorPeachy,
          <int, Color>{
            50: Color(colorPeachy),
            100: Color(colorPeachy),
            200: Color(colorPeachy),
            300: Color(colorPeachy),
            400: Color(colorPeachy),
            500: Color(colorPeachy),
            600: Color(colorPeachy),
            700: Color(colorPeachy),
            800: Color(colorPeachy),
            900: Color(colorPeachy),
          },
        ),
      ),
      home: MyHomePage(title: '출퇴근 확인'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [OffWork(), OffWorkList()];
  bool screenMode = true;

  void checkSetState() {
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return screenMode
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: GestureDetector(
                onTap: () {
                  Timer(Duration(seconds: 180), () {
                    screenMode = true;
                    checkSetState();
                  });
                  screenMode = false;
                  checkSetState();
                },
                child: Image.asset(
                  'assets/images/screen.gif',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                widget.title,
                style: TextStyle(),
                maxLines: 1,
              ),
              // title: Stack(
              //   children: [
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text(
              //           widget.title,
              //           style: TextStyle(),
              //           maxLines: 1,
              //         ),
              //       ],
              //     ),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       children: [
              //         Text(
              //           "미승시앤에스(주)",
              //           style: TextStyle(),
              //           maxLines: 1,
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Color(colorPeachy),
              fixedColor: Color(colorDeepTeal),
              iconSize: 35,
              selectedFontSize: 20,
              unselectedFontSize: 20,
              onTap: (index) => {
                setState(() {
                  _currentIndex = index;
                })
              },
              currentIndex: _currentIndex,
              items: [
                new BottomNavigationBarItem(
                  icon: Icon(Icons.directions_run),
                  label: '퇴근',
                ),
                new BottomNavigationBarItem(
                  icon: Icon(Icons.view_list),
                  label: '목록',
                ),
              ],
            ),
            body: _children[_currentIndex],
          );
  }
}
