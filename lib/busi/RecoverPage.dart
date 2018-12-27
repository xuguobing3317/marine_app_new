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
        backgroundColor: Colors.greenAccent,
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white70,),
        //     tooltip: 'Air it',
        //     onPressed: scanCode,
        //   ),
        // ],
      ),
      // floatingActionButton: new FloatingActionButton(
      //     onPressed: () {
      //       _forSubmitted(_owner, context);
      //     },
      //     child: Icon(Icons.add),
      //     // new Text('回收',style: TextStyle(fontSize: 16.0),),
      //     backgroundColor: Colors.greenAccent,
      //     elevation:10.0,
      //     highlightElevation:20.0,
      //     mini: false,
      //     shape: new CircleBorder(side: BorderSide(width: 10)),
      //   ),
      body: 
        new SingleChildScrollView (
        child: new ConstrainedBox(
          constraints: new BoxConstraints(
            minHeight: 200.0,
          ),
          child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
                _geneBoatNo2(_geneBoatNo('船舶编号', 'boatNo',w3:_w3()), _div()),
                _geneBoatNo2(_geneOtherNo('船舶所有人', 'owner'), _div()),
                _geneBoatNo2(_geneOtherNo('入港次数', 'count'), _div()),
                _geneBoatNo2(_geneOtherNo('已回收重量','recoverWeight'), _div()),
                _geneBoatNo2(_geneOtherNo('船舶吨位','boatUnit'), _div()),
                _geneBoatNo2(_geneOtherNo('船籍港','boatBelong'), _div()),
                _geneBoatNo2(_geneOtherNo('船舶类型','boatType'), _div2()),
                _geneBoatNo2(_geneOtherNo('污染物种类','fomesType'), _div()),
                _geneBoatNo2(_geneOtherNo('上次来港','lastTime'), _div()),
                _geneBoatNo2(_geneOtherNo('重量(KG)','fomesWeight'), _div()),
                _geneBoatNo2(_geneRecoverDate('回收时间','recoverDate',w3:_w4()), _div()),
                _geneBoatNo2(_button2('','')),
               
        ],
      )
        ),
      ),
      
      );
  }

  Widget _div2(){
    return new Container(
      color: Colors.greenAccent,
      height: 5.0,
      child: new Divider(),
    );
  }

  Widget _div(){
    return new Container(
      height: 1.0,
      child: new Divider(color: Colors.greenAccent,),
    );
  }

  Future _timeFocusNodeListener() async {
      if (_timeFocusNode.hasFocus){
          // toSetTime();
      } else {
        // print(_dateTime);
      }
  }

  Widget _button() {
    return new Container(
        child: new Column(
          children: <Widget>[ IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          ),IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          )
          ],
        ),
      );
  }

  Widget _geneBoatNo2(Widget w1, [Widget w2]) {
      return new Container(
        child: new Column(
          children: <Widget>[
            w1,
           null==w2?new Container():w2
          ],
        ),
      );
  }

  Widget _w3() {
    return  IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.greenAccent,),
            onPressed: scanCode,
          );
  }

   Widget _w4() {
    return  IconButton(
            icon: Icon(Icons.date_range, size: 40.0, color: Colors.greenAccent,),
            onPressed: toSetTime,
          );
  }

  Widget _geneOtherNo (_title, _key, {Widget w3}) {
  return new Container(
      color: Colors.white70,
      height: 40.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          new Container(
            width: 100.0,
            child: new Text('$_title:', overflow:TextOverflow.ellipsis,softWrap:false, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.0, color: Colors.black45,fontWeight: FontWeight.w700),),
          ),
          Expanded(
            child:
            new Container(
              alignment: Alignment.center,
              child: new TextField(
                        // controller: boatController,
                        // focusNode: _focusNode,
                        onChanged: (world) {
                            if (_key == 'boatNo') {
                              _boatNo = world;
                            } else if (_key == 'owner') {
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
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: '请输入$_title ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0),
                              ),
                        ),
            ),
          ),
          null==w3?new Container(
            child: IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          ),
          ):w3
      ]
    ),
    );
  }


  Widget _geneBoatNo (_title, _key, {Widget w3}) {
  return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          new Container(
            width: 100.0,
            child: new Text('$_title:', overflow:TextOverflow.ellipsis,softWrap:false, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.0, color: Colors.black45,fontWeight: FontWeight.w700),),
          ),
          Expanded(
            child:
            new Container(
              alignment: Alignment.center,
              child: new TextField(
                        controller: boatController,
                        onChanged: (world) =>_boatNo = world,
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: '请输入$_title ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0),
                              ),
                        ),
            ),
          ),
          null==w3?new Container(
            child: IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          ),
          ):w3
      ]
    ),
    );
  }

  
  Widget _button2 (_title, _key, {Widget w3}) {
  return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          new Container(
            width: 50.0,
            child: new Text('$_title', overflow:TextOverflow.ellipsis,softWrap:false, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.0, color: Colors.black45,fontWeight: FontWeight.w700),),
          ),
          Expanded(
            child:
            new Container(
              padding: new EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
              child: new RaisedButton(
                color: Colors.greenAccent,
                textTheme: ButtonTextTheme.normal,
                elevation: 10,
                highlightElevation: 10,
                disabledElevation: 10,
                child: new Text('立  即  回  收',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16.0),),
                onPressed: (){
                  _forSubmitted(_owner, context);
                },
              ),
          )),
          null==w3?new Container(
            width: 50.0,
            child: IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          ),
          ):w3
      ]
    ),
    );
  }

  
  Widget _geneRecoverDate (_title, _key, {Widget w3}) {
  return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          new Container(
            width: 100.0,
            child: new Text('$_title:', overflow:TextOverflow.ellipsis,softWrap:false, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.0, color: Colors.black45,fontWeight: FontWeight.w700),),
          ),
          Expanded(
            child:
            new Container(
              alignment: Alignment.center,
              child: new TextField(
                        controller: timeController,
                        focusNode: _timeFocusNode,
                        onChanged: (world) =>_recoverDate = world,
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: '请输入$_title ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0),
                              ),
                        ),
            ),
          ),
          null==w3?new Container(
            child: IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          ),
          ):w3
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
