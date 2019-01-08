//服务器URL
const BaseUrl = 'http://40.73.5.106:10522/api';

//登录URL
//params:UserName Password
const LoginUrl = '$BaseUrl/Account/Login';

//船舶列表URL
const BoatListUrl = '$BaseUrl/ShipBasal/GetShipList';

//港口列表查询
const FactListUrl = '$BaseUrl/FactData/GetFactList';

//船舶分析列表查询
const BoatAnalyseListUrl  = '$BaseUrl/ShipBasal/ShipAnalyse';

//密码修改接口
const ModifyPwdUrl = '$BaseUrl/Account/Pwdchange';


//回收分析列表查询
const RubiAnalyseListUrl  = '$BaseUrl/RubishBasal/RubiAnalyse';



//回收分析列表查询
const GetLastRubishDataUrl  = '$BaseUrl/ShipBasal/GetLastRubishData';

