
//登录页面
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/screenutil_init.dart';
import 'package:flutter_shop/register.dart';
import 'package:flutter_shop/urls.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProgressDialog.dart';
import 'ValidateUtils.dart';
import 'api.dart';
import 'main_web.dart';

void main(){
  runZoned(()=>{
    runApp(LoginPage())
  },
  zoneSpecification: ZoneSpecification(
    print: (Zone self,ZoneDelegate delegate,Zone zone,String line){
      delegate.print(zone, "intercept '$line'");
    }
  ));
}

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }

}

/**
 * 显示界面
 */
class _LoginState extends State<LoginPage>{

  Future<SharedPreferences> sp = SharedPreferences.getInstance();

  //焦点
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();

  FocusNode _foucsNodeVerify = new FocusNode();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _verifyController = new TextEditingController();


  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _username = ''; //用户名
  var _password = ''; //密码

  String phone = ""; //电话号码
  String verify = ""; //验证码

  bool isBtnEnabled = true; //发送验证码按钮的状态
  String btnText="发送验证码";
  int count = 60; //倒计时时间
  Timer timer;  //倒计时的计时器

  @override
  void initState() {

    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    _userNameController.addListener(() {
      phone = _userNameController.text.toString();
      print(phone);
    });
    _verifyController.addListener(() {
      verify = _verifyController.text.toString();
      print("$verify");
    });
    initLogin();
    super.initState();
  }

  @override
  void dispose() {
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    _foucsNodeVerify.removeListener(_focusNodeListener);
    if(timer != null){
      timer.cancel();
      timer = null;
    }
    super.dispose();
  }

  void stopTimer(){
    if(timer != null){
      timer.cancel();
      timer = null;
    }
  }

  /**
   * 初始化登录页面
   */
  void initLogin() async {
    final SharedPreferences _sp = await sp;
    String username = _sp.getString("username");
    if(username != null){
      _userNameController.text = username;
    }
  }

  //焦点的监听
  Future<Null> _focusNodeListener() async {
    if(_focusNodeUserName.hasFocus){
      _focusNodePassWord.unfocus();
    }
    if(_focusNodePassWord.hasFocus){
      _focusNodeUserName.unfocus();
    }
  }

  String validatePassword(value){
    if(value.isEmpty){
      return "密码不能为空";
    }else if(value.trim().length < 6 || value.trim().length > 18){
      return "密码的长度不正确";
    }
    return null;
  }

  //保存token username表示手机号
  void _saveToken(String username,String token) async{
    final SharedPreferences _sp = await sp;
    _sp.setString("username", username);
    _sp.setString("token", token);
  }

  //验证码
  /**
   * 开启倒计时
   */
  void _initTimer(){
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      count --;
      setState(() {
        if(count == 0){
          timer.cancel();
          isBtnEnabled = true;
          count = 60;
          btnText = "发送验证码";
        }else{
          btnText = "重新发送($count)";
        }
      });
    });
  }

  /**
   * 发送验证码点击事件
   */
  void sendVerifyCodeClickListener(){
    setState(() {
      if(isBtnEnabled){
        isBtnEnabled = false;
        _initTimer();
        return null;
      }else{
        return null;
      }
    });
  }

  //登录手机号输入区
  Widget userArea(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 20,right: 20),
      color: Colors.amber[20],
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 1,color: Colors.black12)
          )
      ),
      padding:EdgeInsets.only(top: 10,bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          DropdownButton(
            items: [
              DropdownMenuItem(child: Text("中国大陆(+86)"),value: 0,),
              DropdownMenuItem(child: Text("中国香港(+852)"),value: 1,),
              DropdownMenuItem(child: Text("中国澳门(+853)"),value: 2,),
              DropdownMenuItem(child: Text("中国台湾(+886)"),value: 3,),
            ],onChanged: (value){
            //选择的内容
            print("phone:"+value);
          },
            value: 0,
            underline: Container(height: 0,),
          ),
          SizedBox(
            width: 1,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.grey[500]
              ),
            ),
          ),
          Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: TextField(
                  controller: _userNameController,
                  focusNode: _focusNodeUserName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color:Colors.grey[500],
                  ),
                  decoration: InputDecoration(
                    hintText: "请输入手机号",
                    border: InputBorder.none,
                  ),
                ),
              )
          )
        ],
      ),
    );
  }

  Widget verifyCodeArea(BuildContext context) => new Container(
    child: Column(
      children: <Widget>[
        Container(
          color:Colors.white,
          padding: EdgeInsets.only(left:20,right:20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              Text("验证码",style: TextStyle(fontSize: ScreenUtil().setSp(30),),),
              Expanded(
                child: Padding(
                  padding:EdgeInsets.only(left: 15,right: 15,top: 0),
                  child: TextFormField(
                    maxLines: 1,
                    onSaved: (value){

                    },
                    controller: _verifyController,
                    focusNode: _foucsNodeVerify,
                    textAlign: TextAlign.left,
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(6)],
                    decoration: InputDecoration(
                      hintText: ("填写验证码"),
                      contentPadding: EdgeInsets.only(top:0,bottom:0),
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: ScreenUtil().setSp(30),
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              Container(
                width: 120,
                child: FlatButton(
                  disabledColor: Colors.grey.withOpacity(0.1),
                  disabledTextColor: Colors.white,
                  textColor: isBtnEnabled?Colors.white:Colors.black.withOpacity(0.2),
                  color: isBtnEnabled?Color(0xff44c5fe):Colors.grey.withOpacity(0.1),
                  splashColor: isBtnEnabled?Colors.white.withOpacity(0.1):Colors.transparent,
                  shape:StadiumBorder(side:BorderSide.none),
                  onPressed: (){
                    //判断是否有输入手机号
                    String validate = ValidateUtils.validatePhone(phone);
                    if(validate != null && validate.isNotEmpty){
                      Fluttertoast.showToast(msg: validate);
                      return;
                    }
                    //获取验证码
                    String url = ServiceApi.xy_verify;
                    Map<String,dynamic> map = Map();
                    map["user"] = phone;
                    Urls.postX(url, (result){
                      var verify = json.decode(result.toString());
                      if(verify["_status"] == "success"){

                      }
                    },map);
                    setState(() {
                      sendVerifyCodeClickListener();
                    });
                  },
                  child: Text('$btnText',style: TextStyle(fontSize: 13),),
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );

  //注册提示
  Widget registerTextArea(BuildContext context) => new Container(
    margin: EdgeInsets.only(left: 20,right: 20),
    height: 20,
    child: Text.rich(
        TextSpan(
            children: [
              TextSpan(
                text: "还没有账号？",
                style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Colors.grey),
              ),
              TextSpan(
                text: "去注册",
                style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Colors.blue),
                //设置点击事件
                recognizer: TapGestureRecognizer()
                  ..onTap = (){
                    //跳转到注册页面
                    /*Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RegisterPage()
                  )).then((resultData) => {

                  });*/
                    //停掉验证码倒计时
                    stopTimer();
                    //接收下一个页面的回传值
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => RegisterPage()
                    )).then((value){
                      phone = value;
                      _userNameController.text = value;
                    });
                  },
              )
            ]
        )
    ),

  );

  //登录按钮
  Widget loginButtonArea(BuildContext context) => new Container(
    margin: EdgeInsets.only(left:20,right:20),
    height: 45,
    child: new RaisedButton(
        color: Colors.blue[300],
        child: Text("登录",style: Theme.of(context).primaryTextTheme.headline,),
        //设置圆角
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (){
          //登录判断是否输入手机号和验证码
          if(phone.isEmpty || verify.isEmpty){
            Fluttertoast.showToast(
                msg: "请输入正确的手机号或验证码"
            );
            return;
          }
          //点击登录回收键盘，解除焦点
          _focusNodeUserName.unfocus();
          _focusNodePassWord.unfocus();
          //if(_formKey.currentState.validate()){
          //验证通过执行保存操作
          //_formKey.currentState.save();
          //登录
          print("username:$_username password:$_password");
          String url = ServiceApi.xy_login;
          Map<String,dynamic> map = Map();
          map["mobile"] = phone;
          ProgressDialog.showProgress(context,child: SpinKitCircle(
            itemBuilder: (_,int index){
              return DecoratedBox(
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red
                ),
              );
            },
          ));
          Urls.postX(url, (result){
            var login = json.decode(result.toString());
            ProgressDialog.dismiss(context);
            if(login["_login"]){
              var token = login["token"];
              _saveToken(phone,token);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (BuildContext context)=>WebViewPage()),
                      (route)=>route == null);

            }else if(login["_status"] != "success"){
              //登录失败给出错误提示
              var err = login["_err"]["msg"];
              Fluttertoast.showToast(msg: '$err');
            }
          },map);
        }
      //},
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(750,1334),
        allowFontScaling: false,
        builder: ()=>Scaffold(
          backgroundColor: Colors.white,
          // 外层添加一个手势，用户点击空白部分回收键盘
          body:new GestureDetector(
            onTap: (){
              print("点击空白地方");
              _focusNodeUserName.unfocus();
              _focusNodePassWord.unfocus();
            },
            child: new ListView(
              children: [
                new SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child:Column(
                    children: [
                      Image.asset("assets/imgs/xingyuan72.png"),
                      Text(
                        "星 猿",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text(
                    "登录",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                new SizedBox(height: 30,),
                //inputTextArea,
                userArea(),
                verifyCodeArea(context),
                new SizedBox(height: 30,),
                registerTextArea(context),
                new SizedBox(height: 10,),
                loginButtonArea(context),
              ],
            ),
          ),
        )
    );
  }
}

