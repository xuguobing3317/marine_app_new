import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/HomePage.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';



class RecoverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecoverPageState();
}


class RecoverPageState extends State<RecoverPage> {
  

  String _boatNo = ""; //船舶编号
  String _owner = ""; //船舶所有人
  String _count = "";//次数
  String _recoverWeight = ""; //已回收重量
  String _boatUnit = ""; //船舶吨位
  String _boatBelong = ""; //船集港
  String _boatType = ""; //船舶类型

  String _fomesType = ""; //污染物种类
  String _lastTime = ""; //上次来港
  String _fomesWeight = ""; //重量
  String _recoverDate = ""; //回收日期
  
  String barcode = "";

  String _dateTime = "";
  FocusNode _focusNode = new FocusNode();
  FocusNode _timeFocusNode = new FocusNode();

  final TextEditingController boatController = new TextEditingController();
  final TextEditingController timeController = new TextEditingController();


  @override
  void initState() {
    super.initState();
    _timeFocusNode.addListener(_timeFocusNodeListener);
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('污染物回收'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white70,),
            tooltip: 'Air it',
            onPressed: scanCode,
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            _forSubmitted(_owner, context);
          },
          child: Icon(Icons.add),
          // new Text('回收',style: TextStyle(fontSize: 16.0),),
          backgroundColor: Colors.greenAccent,
          elevation:10.0,
          highlightElevation:20.0,
          mini: false,
          shape: new CircleBorder(),
        ),
      body: 
        new SingleChildScrollView (
        child: new ConstrainedBox(
          constraints: new BoxConstraints(
            minHeight: 200.0,
          ),
          child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
                _geneBoatNo(),
                // _geneChild('船舶编号', 'boatNo'),
                _geneChild('船舶所有人', 'owner'),
                _geneChild('入港次数', 'count'),
                _geneChild('已回收重量','recoverWeight'),
                _geneChild('船舶吨位','boatUnit'),
                _geneChild('船籍港','boatBelong'),
                _geneChild('船舶类型','boatType'),
                _geneChild('污染物种类','fomesType'),
                _geneChild('上次来港','lastTime'),
                _geneChild('重量(KG)','fomesWeight'),
                _geneRecoverDate(),
                new Divider(
                  height:15.0,
                  indent:10.0,
                ),
        ],
      )
        ),
      ),
      
      );
  }

   Widget _geneChild (title, _key) {
    return new Container(
      color: Colors.white70,
      height: 60.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          Expanded(
            child:new Container(
              alignment: Alignment.center,
              child: new TextField(
                          onChanged: (world) {
                            // if (_key == 'boatNo') {
                            //   _boatNo = world;
                            // } else
                             if (_key == 'owner') {
                              _owner = world;
                            } else if (_key == 'count') {
                              _count = world;
                            } else if (_key == 'recoverWeight') {
                              _recoverWeight = world;
                            } else if (_key == 'boatUnit') {
                              _boatUnit = world;
                            } else if (_key == 'boatBelong') {
                              _boatBelong = world;
                            } else if (_key == 'boatType') {
                              _boatType = world;
                            } else if (_key == 'fomesType') {
                              _fomesType = world;
                            } else if (_key == 'lastTime') {
                              _lastTime = world;
                            } else if (_key == 'fomesWeight') {
                              _fomesWeight = world;
                            } else if (_key == 'recoverDate') {
                              _recoverDate = world;
                            }
                          },
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                              hintText: '请输入$title',
                              labelText: title,
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0)),
                        ),
            ),
          ),
      ]
    ),
    );
  }

  Future _timeFocusNodeListener() async {
      if (_timeFocusNode.hasFocus){
          // toSetTime();
      } else {
        // print(_dateTime);
      }
  }


  Widget _geneBoatNo () {
  return new Container(
      color: Colors.white70,
      height: 60.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          Expanded(
            child:
            new Container(
              alignment: Alignment.center,
              child: new TextField(
                        controller: boatController,
                        focusNode: _focusNode,
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                              hintText: '请扫描二维码',
                              labelText: '船舶编号',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0),
                              // suffixIcon: Icon(Icons.photo_camera),
                              ),
                        ),
            ),
          ),
      ]
    ),
    );
  }

  
  Widget _geneRecoverDate () {
  return new Container(
      color: Colors.white70,
      height: 60.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          Expanded(
            child:
            new Container(
              alignment: Alignment.center,
              child: new TextField(
                        onTap: toSetTime,
                        controller: timeController,
                        focusNode: _timeFocusNode,
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                              hintText: '请选择回收日期',
                              labelText: '回收日期',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0),
                              suffixIcon: Icon(Icons.date_range),),
                        ),
            ),
          ),
      ]
    ),
    );
  }
  

  Future<Null> toSetTime() async {
    DatePicker.showDatePicker(context, showTitleActions: true, onChanged: (date) {
            _dateTime = date.year.toString() + '-' + date.month.toString() + "-" + date.day.toString();
        }, onConfirm: (date) {
             _dateTime = date.year.toString() + '-' + date.month.toString() + "-" + date.day.toString();
             timeController.text = _dateTime;
        }, locale: LocaleType.zh);
  }

  Future<void> scanCode() async {
    print('开始扫描二位吗');
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        boatController.text = barcode;
        return this.barcode = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return this.barcode = '';
        });
      } else {
        setState(() {
           Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return this.barcode = '';
        });
      }
    } on FormatException{
      setState(() {
           Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return this.barcode = '';
        });
    } catch (e) {
      setState(() {
           Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return this.barcode = '';
        });
    }
  }

  

  Future<bool> _forSubmitted(String _fileOwner, BuildContext context) async {
     try {
    if (barcode == '') {
        Fluttertoast.showToast(
              msg: " 请扫描船舶二维码 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
    }


    if (_fileOwner == '') {
        Fluttertoast.showToast(
              msg: " 请输入船舶所有人 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
    }

    String url =
        "http://116.62.149.237:8080/USR000100001?usrName=admin&passwd=123456";

   
      // result = await http.get(url).then((http.Response response) {
        // var data = json.decode(response.body);
        // String rescode = data["rescode"];
        String rescode = '000000';
        if (_owner == '1') {
          rescode = '999999';
        }
        
        if (rescode == '999999') {
          Fluttertoast.showToast(
              msg: " 回收失败 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
        } else if (rescode == '000000') {
          Navigator.of(context).push(new PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) {
                  return new HomePage();
                },
              ));
          Fluttertoast.showToast(
              msg: "  回收成功！ ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
        }
    } catch (e) {
      Fluttertoast.showToast(
              msg: "  回收失败 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
      return false;
    }
    return true;
  }

}
