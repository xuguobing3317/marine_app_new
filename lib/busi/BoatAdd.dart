import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'BoatPage.dart';

class BoatAddPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return new BoatAddPageState();
  }
}

class BoatAddPageState extends State<BoatAddPage> {
  final TextEditingController carNoController = new TextEditingController();
  final TextEditingController carBelongController = new TextEditingController();
  final TextEditingController carUnitController = new TextEditingController();
  final TextEditingController carOwnerController = new TextEditingController();
  final TextEditingController carContactController = new TextEditingController();
  bool isLoading = false;


   List<PickerItem> boatTypeItems = new List();
  List<Map> boatTypeList = [
    {'rbCode': 'Nl', 'rbName': '常规船只'},
    {'rbCode': 'Dg', 'rbName': '危险品船只'}
  ];

   List<PickerItem> gkTypeItems = new List();
  List<Map> gkTypeList = [
    {'rbCode': 'A', 'rbName': '常规港口'},
    {'rbCode': 'B', 'rbName': '危险品港口'}
  ];

  String facIdName = ""; //港口信息
  String facId = ""; //港口信息代码
  String carNo = ""; //船舶牌照
  String carType = ""; //船舶类型
  String carTypeName = ""; //船舶类型
  String carBelong = ""; //船港籍
  String carUnit = ""; //船吨位
  String carOwner = ""; //船主
  String carContact = ""; //联系方式

  @override
  void initState() {
    super.initState();
    boatTypeList.forEach((item) {
        PickerItem gangkouItem = new PickerItem(text: Text(item['rbName']));
        boatTypeItems.add(gangkouItem);
      });
      gkTypeList.forEach((item) {
        PickerItem gangkouItem = new PickerItem(text: Text(item['rbName']));
        gkTypeItems.add(gangkouItem);
      });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          '新增船舶'
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: isLoading?loading():geneColumn(),
    );
  }

  Widget loading() {
    return new Stack(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
          child: new Center(
            child: SpinKitFadingCircle(
              color: Colors.greenAccent,
              size: 30.0,
            ),
          ),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
          child: new Center(
            child: new Text('船舶信息保存中...', style: TextStyle(color: Colors.greenAccent),),
          ),
        ),
      ],
    );
  }

  Widget geneColumn() {
    return 
    
    new SingleChildScrollView(
        child: new ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 200.0,
            ),
            child: 
    new Column(children: <Widget>[
      _geneRow2('船舶类型', carTypeName, w3:_boatType()),
      _div(),
      _geneRow('船舶牌照', 'carNo', carNoController),
      _div(),
      _geneRow('船港籍', 'carBelong', carBelongController),
      _div(),
      _geneRow('船吨位', 'carUnit', carUnitController),
      _div(),
      _geneRow('船主', 'carOwner', carOwnerController),
      _div(),
      _geneRow('联系方式', 'carContact', carContactController),
      _div(),
      geneButton('', ''),
    ])));
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
                color: Colors.greenAccent,
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
                onPressed: _forSubmitted
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

  Future<bool> _forSubmitted() async {
    setState(() {
          isLoading = true;
        });
    try {
      if (carType == '') {
        Fluttertoast.showToast(
            msg: " 请选择船舶类型 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
            setState(() {
          isLoading = false;
        });
        return false;
      }

      if (carNo == '') {
        Fluttertoast.showToast(
            msg: " 请输入船舶牌照 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }


      if (carBelong == '') {
        Fluttertoast.showToast(
            msg: " 请输入船港籍 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }

      

      if (carUnit == '') {
        Fluttertoast.showToast(
            msg: " 请输入船吨位 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }

      if(!RegExp(r'^\d+(\.\d+)?$').hasMatch(carUnit)) {
      Fluttertoast.showToast(
            msg: " 请输入正确的船吨位 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }
      

      if (carOwner == '') {
        Fluttertoast.showToast(
            msg: " 请输入船主 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }
      

      if (carContact == '') {
        Fluttertoast.showToast(
            msg: " 请输入联系方式 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }

      Map<String, String> _params = {
        'CARTYPE': carType,
        'CARNO1': carNo,
        'CARVENDID': carBelong,
        'CARCAP': carUnit,
        'EMPID': carOwner,
        'MEMO': carContact,
    };
    String url = marineURL.BoatSaveUrl;
    DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
    String dbPath = await marineUser.createNewDb();
    Map uMap = await marineUser.getFirstData(dbPath);
    if (uMap == null) {
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    }

    DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
    String _token = mUser.token;
    Map<String, String> headers = {'token': _token};
    await http.post(url, body: _params, headers: headers).then((http.Response response) {
        var data = json.decode(response.body);
        print('请求报文:body:$_params');
        print('请求报文:headers:$headers');
        print('响应报文:$data');
        int type = data[AppConst.RESP_CODE];
        String rescode = '$type';
        String resMsg = data[AppConst.RESP_MSG];

    
      if (rescode != '10') {
        Fluttertoast.showToast(
            msg: " 保存失败[$resMsg] ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      } else {
        Navigator.of(context).pushReplacement(new PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
            return new BoatPage();
          },
        ));
        Fluttertoast.showToast(
            msg: "  保存成功！ ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
            return true;
      }}
      );
    }catch(e) {
      debugPrint(e);
      Fluttertoast.showToast(
            msg: " 保存失败 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
    }
     setState(() {
          isLoading = false;
        });
    return true;
  }

  Widget _div() {
    return new Container(
      height: 1.0,
      child: new Divider(
        color: Colors.greenAccent,
      ),
    );
  }


  Widget _gkType() {
    return IconButton(
      icon: Icon(
        Icons.navigation,
        size: 30.0,
        color: Colors.greenAccent,
      ),
      onPressed: showGkTypePicker,
    );
  }

  showGkTypePicker() {
    Picker picker = new Picker(
        adapter: PickerDataAdapter(
          data: gkTypeItems,
        ),
        changeToFirst: true,
        textAlign: TextAlign.left,
        cancelText: '取消',
        cancelTextStyle: TextStyle(color: Colors.greenAccent),
        confirmText: '确定',
        confirmTextStyle: TextStyle(color: Colors.greenAccent),
        textStyle: TextStyle(fontSize: 30.0),
        // hideHeader: true,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          String _value = value[0].toString();
          int index = int.parse(_value);
          setState(() {
            facIdName = gkTypeList[index]['rbName'];
            facId = gkTypeList[index]['rbCode'];
          });
        });
    picker.showModal(context);
    // picker.show(_scaffoldKey.currentState);
  }


  Widget _boatType() {
    return IconButton(
      icon: Icon(
        Icons.directions_boat,
        size: 30.0,
        color: Colors.greenAccent,
      ),
      onPressed: showBoatTypePicker,
    );
  }

  showBoatTypePicker() {
    Picker picker = new Picker(
        adapter: PickerDataAdapter(
          data: boatTypeItems,
        ),
        changeToFirst: true,
        textAlign: TextAlign.left,
        cancelText: '取消',
        cancelTextStyle: TextStyle(color: Colors.greenAccent),
        confirmText: '确定',
        confirmTextStyle: TextStyle(color: Colors.greenAccent),
        textStyle: TextStyle(fontSize: 30.0),
        // hideHeader: true,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          String _value = value[0].toString();
          int index = int.parse(_value);
          setState(() {
            carTypeName = boatTypeList[index]['rbName'];
            carType = boatTypeList[index]['rbCode'];
          });
        });
    picker.showModal(context);
    // picker.show(_scaffoldKey.currentState);
  }

  Widget _geneRow2(String _title, String _key,
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
                child: new Text(
                  (_key == null || _key.isEmpty)?'请选择$_title':_key,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black38,
                      fontWeight: FontWeight.w400),
                )
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
