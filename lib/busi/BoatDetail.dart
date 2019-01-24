import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/HomePage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marine_app/common/AppConst.dart';

class BoatDetailPage extends StatefulWidget {
  final String facId;
  final String carType;
  final String carNo;
  final String carBelong;
  final String carUnit;
  final String carOwner;
  final String carContact;

  BoatDetailPage(
      {this.facId,
      this.carType,
      this.carNo,
      this.carBelong,
      this.carUnit,
      this.carOwner,
      this.carContact});

  @override
  State<StatefulWidget> createState() {
    return new BoatDetailPageState(
        facId: facId,
        carType: carType,
        carNo: carNo,
        carBelong: carBelong,
        carUnit: carUnit,
        carOwner: carOwner,
        carContact: carContact);
  }
}

class BoatDetailPageState extends State<BoatDetailPage> {
  String facId;
  String carType;
  String carNo;
  String carBelong;
  String carUnit;
  String carOwner;
  String carContact;
  BoatDetailPageState(
      {this.facId,
      this.carType,
      this.carNo,
      this.carBelong,
      this.carUnit,
      this.carOwner,
      this.carContact});

  String facIdName = ""; //港口信息
  String carTypeName = ""; //船舶类型
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    isLoading = true;
    await Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if(facId == 'A') {
            facIdName = "常规港口";
        } else {
          facIdName = "危险品港口";
        }
        if(carType == 'Nl') {
            carTypeName = "常规船只";
        } else {
          carTypeName = "危险品船只";
        }
      });
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('船舶详情'),
        backgroundColor: AppConst.appColor,
      ),
      body: isLoading ? loading() : geneColumn2(),
    );
  }

  Widget loading() {
    return new Stack(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
          child: new Center(
            child: SpinKitFadingCircle(
              color: AppConst.appColor,
              size: 30.0,
            ),
          ),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
          child: new Center(
            child: new Text(
              '船舶信息加载中...',
              style: TextStyle(color: AppConst.appColor),
            ),
          ),
        ),
      ],
    );
  }


  Widget geneColumn2() {
    return new Column(children: <Widget>[
      _geneRow3('船舶类型', carTypeName),
      _div(),
      _geneRow3('船舶牌照', carNo),
      _div(),
      _geneRow3('船港籍', carBelong),
      _div(),
      _geneRow3('船吨位', carUnit),
      _div(),
      _geneRow3('船主', carOwner),
      _div(),
      _geneRow3('联系方式', carContact),
    ]);
  }

  Widget geneButton(_title, _key, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 60.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 50.0,
              child: new Text(
                '$_title',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
                child: new Container(
              padding: new EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 0.0),
              child: new RaisedButton(
                color: AppConst.appColor,
                elevation: 10,
                highlightElevation: 10,
                disabledElevation: 10,
                child: new Text(
                  '保 存',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0),
                ),
                onPressed: () {
                  _forSubmitted(facId, context);
                },
              ),
            )),
            null == w3
                ? new Container(
                    width: 50.0,
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_enhance,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                  )
                : w3
          ]),
    );
  }

  Future<bool> _forSubmitted(String _fileOwner, BuildContext context) async {
    try {
      if (facId == '') {
        Fluttertoast.instance.showToast(
            msg: " 请输入港口信息 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      }

      String url =
          "http://116.62.149.237:8080/USR000100001?usrName=admin&passwd=123456";

      // result = await http.get(url).then((http.Response response) {
      // var data = json.decode(response.body);
      // String rescode = data["rescode"];
      String rescode = '000000';
      if (rescode == '999999') {
        Fluttertoast.instance.showToast(
            msg: " 保存失败 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      } else if (rescode == '000000') {
        Navigator.of(context).push(new PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
            return new HomePage();
          },
        ));
        Fluttertoast.instance.showToast(
            msg: "  保存成功！ ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
      }
    } catch (e) {
      Fluttertoast.instance.showToast(
          msg: "  保存失败 ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Color(0xFF499292),
          textColor: Color(0xFFFFFFFF));
      return false;
    }
    return true;
  }

  Widget _div() {
    return new Container(
      height: 1.0,
      child: new Divider(
        color: AppConst.appColor,
      ),
    );
  }


  Widget _geneRow3(String _title, String _key) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 100.0,
              child: new Text(
                '$_title:',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: new Container(
                  alignment: Alignment.center,
                  child: new Text(
                    (_key == null || _key.isEmpty) ? '-' : _key,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black38,
                        fontWeight: FontWeight.w400),
                  )),
            )
          ]),
    );
  }

  Widget _geneRow2(String _title, String _key, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 100.0,
              child: new Text(
                '$_title:',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: new Container(
                  alignment: Alignment.center,
                  child: new Text(
                    (_key == null || _key.isEmpty) ? '请选择$_title' : _key,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black38,
                        fontWeight: FontWeight.w400),
                  )),
            ),
            null == w3
                ? new Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_enhance,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                  )
                : w3
          ]),
    );
  }

  Widget _geneRow(String _title, String _key, TextEditingController _controller,
      {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 100.0,
              child: new Text(
                '$_title:',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: new TextField(
                  controller: _controller,
                  onChanged: (world) {
                    if (_key == 'facId') {
                      facId = world;
                    } else if (_key == 'carNo') {
                      carNo = world;
                    } else if (_key == 'carType') {
                      carType = world;
                    } else if (_key == 'carBelong') {
                      carBelong = world;
                    } else if (_key == 'carUnit') {
                      carUnit = world;
                    } else if (_key == 'carOwner') {
                      carOwner = world;
                    } else if (_key == 'carContact') {
                      carContact = world;
                    }
                  },
                  style: new TextStyle(fontSize: 15.0, color: Colors.black),
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: '请输入$_title ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                    hintStyle: TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
            ),
            null == w3
                ? new Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_enhance,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                  )
                : w3
          ]),
    );
  }
}
