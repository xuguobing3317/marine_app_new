class ResponseCodeEnum{
  static final Map codeMap = initCodeMap();
  static Map initCodeMap() {
    Map<String, CodeEnum> _retMap = new Map();
    _retMap["SUCCESS"] = new CodeEnum("000000", "成功");
    _retMap["NETWORK_ERROR"] = new CodeEnum("000001", "网络异常");
  }
}

class CodeEnum{
  String code;
  String desc;
  CodeEnum(this.code, this.desc);
}