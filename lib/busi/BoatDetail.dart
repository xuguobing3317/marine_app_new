import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/HomePage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_picker/flutter_picker.dart';

class BoatDetailPage extends StatefulWidget {
  final String carId;

  BoatDetailPage({this.carId});

  @override
  State<StatefulWidget> createState() {
    return new BoatDetailPageState(carId: carId);
  }
}

class BoatDetailPageState extends State<BoatDetailPage> {
  String carId;
  BoatDetailPageState({this.carId});
  final TextEditingController carNoController = new TextEditingController();
  final TextEditingController carBelongController = new TextEditingController();
  final TextEditingController carUnitController = new TextEditingController();
  final TextEditingController carOwnerController = new TextEditingController();
  final TextEditingController carContactController = new TextEditingController();


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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();

    boatTypeList.forEach((item) {
        PickerItem gangkouItem = new PickerItem(text: Text(item['rbName']));
        boatTypeItems.add(gangkouItem);
      });
      gkTypeList.forEach((item) {
        PickerItem gangkouItem = new PickerItem(text: Text(item['rbName']));
        gkTypeItems.add(gangkouItem);
      });
  }

  Future getData() async {
    if (carId.isNotEmpty) {
      isLoading = true;
      await Future.delayed(Duration(seconds: 1), () {
        setState(() {
          facIdName = "常规港口"; //港口信息
          facId = "A";
          carNo = "CBPZ_000002"; //船舶牌照
          carType = "Nl"; //船舶类型
          carTypeName = "常规船只";
          carBelong = "CGJ_999999"; //船港籍
          carUnit = "CDW_877666"; //船吨位
          carOwner = "CZ_OWNER_123"; //船主
          carContact = "13888888888"; //联系方式
          carNoController.text = carNo;
          carBelongController.text = carBelong;
          carUnitController.text = carUnit;
          carOwnerController.text = carOwner;
          carContactController.text = carContact;
        });
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          carId.isNotEmpty?'船舶详情':'新增船舶'
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: isLoading ? loading() : geneColumn(),
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
            child: new Text('船舶信息加载中...', style: TextStyle(color: Colors.greenAccent),),
          ),
        ),
      ],
    );
  }

  Widget geneColumn() {
    return new Column(children: <Widget>[
      _geneRow2('港口信息', facIdName, w3:_gkType()),
      _div(),
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
        Fluttertoast.showToast(
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
        Fluttertoast.showToast(
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
        Fluttertoast.showToast(
            msg: "  保存成功！ ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
      }
    } catch (e) {
      Fluttertoast.showToast(
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
            facId = boatTypeList[index]['rbCode'];
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
