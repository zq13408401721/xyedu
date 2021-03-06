
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_shop/NetUtils.dart';
import 'package:flutter_shop/ValidateUtils.dart';
import 'package:flutter_shop/api.dart';
import 'package:flutter_shop/html.dart';
import 'package:flutter_shop/time_picker.dart';
import 'package:flutter_shop/urls.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }

}

/**
 * 注册页面状态
 */
class _RegisterPageState extends State<RegisterPage>{

  ///手机号
  TextEditingController _phoneNumEditController;
  /// 验证码
  TextEditingController _verifyCodeEditController;
  ///密码
  TextEditingController _passWordEditController;
  ///密码
  TextEditingController _passWordTwoEditController;
  //昵称
  TextEditingController _nicknameEditController;
  //生日
  TextEditingController _birthDayEditController;

  final FocusNode _phoneNumFocusNode = FocusNode();
  final FocusNode _verifyCodeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordTwoFocusNode = FocusNode();
  final FocusNode _nicknameFocusNode = FocusNode();
  final FocusNode _birthDayFocusNode = FocusNode();

  var areaCode = "+86"; //区号

  //按钮开关变量
  String btnLogin = '';

  bool _isAvailableGetVCode = true; //是否可以获取验证码，默认为`false`
  String _verifyStr = '';
  /// 倒计时的计时器。
  Timer timer;
  /// 当前倒计时的秒数。
  int count=60;
  ///获取的验证码
  String getedCode = '';
  bool isSendEnable = true; //发送验证码按钮的状态
  String btnText="发送验证码";

  ///获取验证码时候的电话
  String phone = '';
  String nickname = ""; //昵称
  String password1 = ""; //密码
  String password2 = ""; //密码重复
  String birthDay = ""; //生日
  static String log = "";
  bool isShowPassword = true; //是否显示密码

  //是否选中协议
  bool isChecked = false;



  @override
  void initState() {
    super.initState();
    _phoneNumEditController = TextEditingController();
    _verifyCodeEditController = TextEditingController();
    _passWordEditController = TextEditingController();
    _passWordTwoEditController = TextEditingController();
    _nicknameEditController = TextEditingController();
    _birthDayEditController = TextEditingController();

    _phoneNumEditController.addListener(() => setState(() => {
      phone = _phoneNumEditController.text.toString()
    }));
    //验证码输入的监听
    _verifyCodeEditController.addListener((){
      _verifyStr = _verifyCodeEditController.text.toString();
    });
    _passWordEditController.addListener((){
        password1 = _passWordEditController.text.toString();
    });
    _passWordTwoEditController.addListener((){
        password2 = _passWordTwoEditController.text.toString();
    });
    _nicknameEditController.addListener((){
        nickname = _nicknameEditController.text.toString();
    });
    _birthDayEditController.addListener((){

    });

    isShowPassword = true;
  }

  //停掉验证码倒计时
  void stopTimer(){
    if(timer != null){
      timer.cancel();
      timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body:new GestureDetector(
        onTap: (){
          print("点击空白地方");
          _phoneNumFocusNode.unfocus();
          _passwordFocusNode.unfocus();
          _passwordTwoFocusNode.unfocus();
          _verifyCodeFocusNode.unfocus();
          _nicknameFocusNode.unfocus();
          //_birthDayFocusNode.unfocus();
        },
        child:WillPopScope(
          onWillPop: () async {
            print("返回键");
            stopTimer();
            return true;
          },
          child: Stack(
              children:[
                Column(
                  children: [
                    appbarUI(context),
                    SizedBox(height: 40,),
                    phoneNumberAreaUI(),
                    SizedBox(height: 10,),
                    nicknameArea(),
                    SizedBox(height: 10,),
                    passwordArea(),
                    SizedBox(height: 10,),
                    passwordRepeatArea(),
                    SizedBox(height: 10,),
                    //birthDayArea(context),
                    //SizedBox(height: 10,),
                    verifyCodeArea(),
                    SizedBox(height: 80,),
                    rigsterButtonArea(),
                  ],
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Checkbox(value: isChecked, onChanged: (select){
                            print('$select');
                            setState(() {
                              isChecked = select;
                            });
                          }),
                          Text.rich(
                              TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "同意",
                                      style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Colors.black54)
                                    ),
                                    TextSpan(
                                        text: "《星猿用户服务协议》",
                                        style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Colors.blue),
                                        //点击用户服务协议
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Html(html:"assets/files/agreement.html",title:"用户服务协议")
                                                )
                                            );
                                          }
                                    ),
                                    TextSpan(
                                        text: "和",
                                        style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Colors.black54)
                                    ),
                                    TextSpan(
                                        text: "《隐私政策说明》",
                                        style: TextStyle(fontSize: ScreenUtil().setSp(30),color:Colors.blue),
                                        //点击政策说明   级联写法
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Html(html: "assets/files/secret.html", title: "隐私政策说明")
                                                )
                                            );
                                          }
                                    )
                                  ]
                              )
                          ),
                        ],
                      ),
                    )
                )
              ]),
        )


      )
    );
  }

  //状态栏
  Widget appbarUI(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top: 30),
      child: Container(
        height: 40,
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: 5,
                child: GestureDetector(
                  child: Image.asset('assets/imgs/ic_arrow_left.png',width: 20,height: 20,),
                  onTap: (){
                    stopTimer();
                    Navigator.pop(context);
                  },
                )
              ),
              Positioned(
                child: Text(
                  "注册",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(50),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //手机号
  Widget phoneNumberAreaUI(){
    return Padding(
      padding: EdgeInsets.only(left: 10,right: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1,color: Colors.black12)
          )
        ),
          padding: EdgeInsets.only(top: 5,bottom: 5),
          child:Row(
            children: [
              DropdownButton(
                items: [
                  DropdownMenuItem(child: Text("中国大陆(+86)"),value: "+86",),
                  DropdownMenuItem(child: Text("中国香港(+852)"),value: "+852",),
                  DropdownMenuItem(child: Text("中国澳门(+853)"),value: "+853",),
                  DropdownMenuItem(child: Text("中国台湾(+886)"),value: "+886",),
                ],onChanged: (value){
                //选择的内容
                print("phone:"+value);
                setState(() {
                  areaCode = value;
                });
              },
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: Colors.black54
                ),
                value: areaCode,
                underline: Container(height: 0,),
              ),
              Container(
                  child: Expanded(
                    child: TextFormField(
                      maxLines: 1,
                      controller: _phoneNumEditController,
                      focusNode: _phoneNumFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(11)],
                      decoration: InputDecoration(
                        hintText: "请输入手机号",
                        border: InputBorder.none,
                      ),
                      //验证手机号
                      validator: ValidateUtils.validatePhone,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          color: Colors.black54
                      ),
                    ),
                  )
              )
            ],
          ),
      ),
    );
  }

  //密码显示区域
  Widget passwordArea(){
    return Padding(
      padding:EdgeInsets.only(left:10,right:10),
      child: Container(
        width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1,color: Colors.black12)
            )
          ),
          padding: EdgeInsets.only(top: 5,bottom: 5),
          child: Row(
            children: [
              Text("登录密码",style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Colors.black54),),
              SizedBox(
                width: 20,
                height: 1,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        height: 30,
                        width: 240,
                        child: TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            obscureText: isShowPassword,
                            controller: _passWordEditController,
                            focusNode: _passwordFocusNode,
                            textAlign: TextAlign.left,
                            inputFormatters: [LengthLimitingTextInputFormatter(18)],
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(30),
                                color: Colors.black54
                            ),
                            decoration: InputDecoration(
                              hintText: "请输入密码",
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                              border: InputBorder.none,
                              /*suffixIcon: IconButton(
                                      icon: Icon(
                                        isShowPassword ? Icons.visibility : Icons.visibility_off,
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                    )*/
                            ))
                    ),
                    Text("6-20位字母、数字组合",style: TextStyle(fontSize: ScreenUtil().setSp(24),color: Colors.grey),)
                  ],
                ),
              ),
            ],
          ),
          /*Column(
            children: [

              Divider(
                height: 1,
                color: Colors.grey,
              )
            ],
          )*/
      ),
    );
  }

  //重复密码
  Widget passwordRepeatArea(){
    return Padding(
      padding: EdgeInsets.only(left: 10,right: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1,color: Colors.black12)
          )
        ),
        padding: EdgeInsets.only(top: 5,bottom: 5),
        child: Row(
          children: [
            Text("确认密码",style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                color:Colors.black54
            ),),
            SizedBox(width: 20,height: 1,),
            Expanded(
              child: TextFormField(
                maxLines: 1,
                obscureText: true,
                keyboardType: TextInputType.text,
                controller: _passWordTwoEditController,
                focusNode: _passwordTwoFocusNode,
                inputFormatters: [LengthLimitingTextInputFormatter(18)],
                decoration: InputDecoration(
                  hintText: "请重复输入密码",
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: Colors.black54
                ),

              ),
            )
          ],
        ),
      )
    );
  }

  //昵称
  Widget nicknameArea(){
    return Padding(
        padding: EdgeInsets.only(left: 10,right: 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1,color:Colors.black12)
            )
          ),
          padding: EdgeInsets.only(top: 5,bottom: 5),
          child: Row(
            children: [
              Container(
                width: 60,
                child: Text("昵    称",style:TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: Colors.black54,
                ),),
              ),
              SizedBox(width: 20,height: 1,),
              Expanded(
                child: TextFormField(
                  maxLines: 1,
                  //obscureText: true,
                  keyboardType: TextInputType.text,
                  controller: _nicknameEditController,
                  focusNode: _nicknameFocusNode,
                  inputFormatters: [LengthLimitingTextInputFormatter(18)],
                  decoration: InputDecoration(
                    hintText: "请输入昵称",
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                    border: InputBorder.none,
                  ),

                ),
              )
            ],
          ),
        )
    );
  }

  //出生日期
  Widget birthDayArea(BuildContext context){
    return Padding(
        padding: EdgeInsets.only(left: 10,right: 10,),
        child: GestureDetector(
          onTap: ()=>{
            PickerTool.showDatePicker(context,dateType: DateType.YY_MM_DD, clickCallBack:(var date,var time){
              setState(() {
                birthDay = date;
              });
            })
          },
          child: Column(
            children: [
              Row(
                children: [
                  Text("出生日期"),
                  SizedBox(width: 30,),
                  Text(birthDay.length == 0 ? "选择出生日期" : birthDay,),
                ],
              ),
              SizedBox(height: 10,),
              Divider(
                height: 1,
                color: Colors.grey,
              )
            ],
          ),
        )
    );
  }

  Widget verifyCodeArea(){
    return Padding(
      padding: EdgeInsets.only(left: 10,right: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1,color: Colors.black12)
          )
        ),
        padding: EdgeInsets.only(top:5,bottom:5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: <Widget>[
            Text("验证码",style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Colors.black54),),
            SizedBox(width: 20,height: 1,),
            Expanded(
              child: TextField(
                maxLines: 1,
                controller: _verifyCodeEditController,
                focusNode: _verifyCodeFocusNode,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(6)],
                decoration: InputDecoration(
                  hintText: ("填写验证码"),
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: ScreenUtil().setSp(30),
                  ),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: ScreenUtil().setSp(30)
                ),
              ),
            ),
            Container(
              width: 130,
              child: FlatButton(
                disabledColor: Colors.grey.withOpacity(0.1),
                disabledTextColor: Colors.white,
                textColor: isSendEnable?Colors.white:Colors.black.withOpacity(0.2),
                color: isSendEnable?Color(0xff44c5fe):Colors.grey.withOpacity(0.1),
                splashColor: isSendEnable?Colors.white.withOpacity(0.1):Colors.transparent,
                shape:StadiumBorder(side:BorderSide.none),
                onPressed: (){
                  //请求验证码
                  String validate = ValidateUtils.validatePhone(phone);
                  if(validate.isNotEmpty){
                    Fluttertoast.showToast(
                        msg: validate,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM
                    );
                    return;
                  }
                  Map<String,dynamic> map = Map();
                  map["user"] = phone;
                  Urls.postX(ServiceApi.xy_verify, (result){
                    print('$result');
                    var res = json.decode(result.toString());
                    if(res["_status"] == "success"){
                      setState(() {
                        sendVerifyCodeClickListener();
                      });
                    }
                  },map);
                },
                child: Text('$btnText',style: TextStyle(fontSize: ScreenUtil().setSp(30)),),
              ),
            )
          ],
        ),
      ),
    );
  }

  //登录按钮
  Widget rigsterButtonArea(){
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: double.infinity
      ),
      child: Container(
        margin: EdgeInsets.only(left:20,right:20),
        height: 40,
        child: new RaisedButton(
            color: Color(0xff44c5fe),
            child: Text("注册",style: TextStyle(fontSize: ScreenUtil().setSp(30),color: Colors.white),),
            //设置圆角
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            onPressed: (){
              //点击登录回收键盘，解除焦点

              if(phone.isEmpty){
                Fluttertoast.showToast(msg: "请输入正确的手机号");
                return;
              }
              String validatePw = ValidateUtils.validatePassword(password1);
              if(validatePw.isNotEmpty){
                Fluttertoast.showToast(msg: validatePw);
                return;
              }
              if(Comparable.compare(password1, password2) != 0){
                Fluttertoast.showToast(msg: "两次输入的密码不一致");
                return;
              }
              if(_verifyStr.isEmpty){
                Fluttertoast.showToast(msg: "请输入验证码");
                return;
              }
              if(nickname.isEmpty){
                Fluttertoast.showToast(msg: "请输入昵称");
                return;
              }
              if(!isChecked){
                Fluttertoast.showToast(msg: "选择服务协议");
                return;
              }
              /*if(birthDay.isEmpty){
                Fluttertoast.showToast(msg: "请选择生日");
                return;
              }*/
              //请求注册的接口
              Map<String,dynamic> map = Map();
              map["user"] = phone;
              //map["pass"] = sha1.convert(utf8.encode(password1)); //sha1加密密码
              map["pass"] = password1;
              map["code"] = _verifyStr;
              map["text"] = nickname;
              //map["birthday"] = birthDay;
              print('$map');
              Urls.postX(ServiceApi.xy_register, (result){
                var register = json.decode(result.toString());
                print("$register");
                if(register["_status"] != "success"){
                  var err = register["_err"]["msg"];
                  Fluttertoast.showToast(msg: '$err');
                }else{
                  //返回上一个页面并把注册成功的手机号传回去
                  Navigator.pop(context,phone);
                }
                //注册成功需要回到登录页面并且回传值
              },map);
            }
        ),
      ),

    );
  }

  void _initTimer(){
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      count --;
      setState(() {
        if(count == 0){
          timer.cancel();
          isSendEnable = true;
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
      if(isSendEnable){
        isSendEnable = false;
        _initTimer();
        return null;
      }else{
        return null;
      }
    });
  }

}