import 'package:flutter/material.dart';

class AppConst {
  static const String RESP_CODE = "type";
  static const String RESP_MSG = "message";
  static const String RESP_DATA = "content";

  static const String SUCCESS = "10"; //成功
  static const String TOKEN_NULL = "11"; //Token为空
  static const String MSG_BODY_FORMAT_ERROR = "12"; //消息正文格式错误
  static const String SOURCE_ERROR = "13"; //来源错误
  static const String TOKEN_ERROR = "14"; //Token错误
  static const String IP_REJECT = "15"; //Ip拒绝
  static const String REQUEST_DATA_FORMAT_ERROR = "16"; //请求数据格式错误
  static const String NETWORK_ERROR = "17"; //网络未知异常
  static const String BUSI_ERROR = "18"; //业务失败原因
  static const String SYS_ERROR = "999999"; //系统异常

  static const String corpName = '鸦雀漾水上服务有限公司';
  static const String teckName = '苏州宝码软件有限公司';

  static String issellead = 'T';

  static bool getIssellead() {
    return issellead == 'T';
  }

  static const Map convert = {
    "10": "成功",
    "11": "Token为空",
    "12": "消息正文格式错误",
    "13": "来源错误",
    "14": "Token错误",
    "15": "Ip拒绝",
    "16": "请求数据格式错误",
    "17": "网络未知异常",
    "18": "业务失败原因",
    "999999": "业务失败原因",
  };

  static Color appColor = Color(0xFF449D44);

  static List<Map> garbageList = [
    {'rbCode': 'A', 'rbName': '船舶油污水'},
    {'rbCode': 'B', 'rbName': '船舶生活垃圾'},
    {'rbCode': 'C', 'rbName': '船舶生活污水'}
  ];


  static List<Map> rbTypeList = 
  [
    {'rbCode': '', 'rbName': '全部', 'rbColor':AppConst.appColor},
    {'rbCode': 'A', 'rbName': '船舶油污水', 'rbColor':Colors.grey},
    {'rbCode': 'B', 'rbName': '船舶生活垃圾', 'rbColor':Colors.grey},
    {'rbCode': 'C', 'rbName': '船舶生活污水', 'rbColor':Colors.grey}
  ];
  
  static Map garbageMap = {
    'A': getGbContainer('油污\n水', Colors.redAccent),
    'B': getGbContainer('生活\n垃圾', Colors.greenAccent),
    'C': getGbContainer('生活\n污水', Colors.blueAccent)
  };

  static Container getGbContainer(String content, Color color) {
    return new Container(
      width: 55.0,
      height: 45.0,
      alignment: Alignment.center,
      decoration: new BoxDecoration(
          border: new Border.all(
            //添加边框
            width: 1.0, //边框宽度
            color: color, //边框颜色
          ),
          // borderRadius: new BorderRadius.circular(20.0),
          shape: BoxShape.circle),
      child: Text(
        // '油污\n水',
        content,
        style: TextStyle(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
