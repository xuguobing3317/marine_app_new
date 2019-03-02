import 'package:flutter/material.dart';
import 'SplashPage.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'dart:io';

void main() {
  runApp(new MyApp());
} 

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '海事系统',
      debugShowCheckedModeBanner: false, 
      theme:
      new ThemeData(
        primarySwatch: Colors.green,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          platform: TargetPlatform.iOS),
      home: new SplashPage(), // 闪屏页
      routes: <String, WidgetBuilder>{ // 路由
        '/LoginPage': (BuildContext context) =>  new MyLoginWidget(),
        '/HomePage': (BuildContext context) =>  new HomePage()
      },
    );
  }


  Widget getHome() {
    if(Platform.isIOS){
      //ios相关代码
      return new MyLoginWidget();
    }else if(Platform.isAndroid){
      //android相关代码
      return new SplashPage();
    }
    return null;
  }
}