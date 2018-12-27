class AppConst {
  static const String RESP_CODE = "responseCode";
  static const String RESP_MSG = "responseDesc";
  static const String RESP_DATA = "data";

  static const String SUCCESS = "000000";
  static const String NETWORK_ERROR = "000001";
  static const String SYS_ERROR = "999999";


  static const String corpName = '鸦雀漾水上服务有限公司';
  static const String teckName = '苏州宝码软件有限公司';

  static const Map convert = {
    "000000":"成功",
    "000001":"网络异常",
    "999999":"业务异常"
  };

}