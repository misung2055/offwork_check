import 'package:flutter/material.dart';

final double fixedFontSize = 20;
final int colorBerry = 0xffBC5F6A;
final int colorDeepTeal = 0xff034B61;
final int colorBlush = 0xffE3A6A1;
final int colorOrchid = 0xffDAB2D3;
final int colorWheat = 0xffF6E0AE;
final int colorArctic = 0xffA9DFED;
final int colorBabyBlue = 0xffBEDAE5;

final int colorPeachy = 0xffFAA98B;
final int colorAzalea = 0xffE6AECF;
final int colorPacificBlue = 0xff01ACBD;
final int colorAqua = 0xffAEE0DD;

final int colorTundra = 0xff9EA2AB;
final int colorGlacierBlue = 0xff6D8DB6;
final int colorTiger = 0xffFFCC71;
final int colorCider = 0xffA16F3a;

final int colorOlivine = 0xff9AB878;
final int colorJasmine = 0xffF2DE99;
final int colorMonarch = 0xffE98D24;
final int colorEbonyClay = 0xff252839;

final int colorBeeswax = 0xfffef0bf;
final int colorCasablanca = 0xfff3b749;
final int colorStormDust = 0xff655c57;
final int colorMikado = 0xff2e1e11;

Widget inputText() {
  return Expanded(
    child: SizedBox(
      child: TextField(
        decoration: new InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(colorPacificBlue), width: 3.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(colorPeachy), width: 3.0),
          ),
          hintText: '이름',
        ),
      ),
    ),
  );
}
