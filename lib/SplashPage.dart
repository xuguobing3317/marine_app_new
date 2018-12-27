import 'dart:async';
import 'package:flutter/widgets.dart';

class SplashPage extends StatefulWidget {
@override
State<StatefulWidget> createState() {
return _SplashPageState();
}
}

class _SplashPageState extends State<SplashPage> {
@override
Widget build(BuildContext context) {
return new Image.asset("images/spash.jpg");
}

@override
void initState() {
super.initState();
countDown();
}

// 倒计时
void countDown() {
var _duration = new Duration(seconds: 1);
new Future.delayed(_duration, go2LoginPage);
}

void go2LoginPage() {
Navigator.of(context).pushReplacementNamed('/LoginPage');
}
}