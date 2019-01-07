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
  static const String SYS_ERROR = "999999";//系统异常


  static const String corpName = '鸦雀漾水上服务有限公司';
  static const String teckName = '苏州宝码软件有限公司';

  static const Map convert = {
    "10":"成功",
    "11":"Token为空",
    "12":"消息正文格式错误",
    "13":"来源错误",
    "14":"Token错误",
    "15":"Ip拒绝",
    "16":"请求数据格式错误",
    "17":"网络未知异常",
    "18":"业务失败原因",
    "999999":"业务失败原因",
  };

}