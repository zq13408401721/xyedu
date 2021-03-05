
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ProgressDialog.dart';

/*void main(){
  runApp(MaterialApp(
    home: WebViewPage(),
    debugShowCheckedModeBanner: false,
  ));
}*/

/**
 * H5显示的主页面
 */
class WebViewPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _WebViewState();
  }
}

//接口回调
typedef _Callback = void Function();

class _WebViewState extends State<WebViewPage>{

  WebViewController _webViewController;
  bool visible=false;
  String title="";
  bool showArrow=false; //是否显示左边箭头

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom,SystemUiOverlay.top]
    );
    if(Platform.isAndroid){
      WebView.platform = SurfaceAndroidWebView();
      visible = true;
    }else if(Platform.isIOS){
       visible = false;
    }
  }

  /**
   * 退出当前应用
   */
  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void updateTitle(String str){
    setState(() {
      this.title = str;
    });
  }

  /**
   * 点击返回处理
   */
  void _goBack(){
    _webViewController.canGoBack().then((value) {
      if (value) {
        _webViewController.goBack();
      }else{
        setState(() {
          showArrow = true;
        });
      }
    },onError: (err){
      print("err:$err");
    });
  }

  @override
  Widget build(BuildContext context) {
    //设置loading
    /*Future.delayed(Duration.zero,(){
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
    });*/
    return ScreenUtilInit(
      designSize: Size(750,1334),
      allowFontScaling: false,
      builder: ()=>GestureDetector(
          child:WillPopScope(
            onWillPop: () async{
              _webViewController.canGoBack().then((value) {
                if (value) {
                  _webViewController.goBack();
                }else{
                  pop();
                }
              });
            },
            child: Scaffold(
              body: SafeArea(
                child: Builder(builder: (BuildContext context) {
                  return Column(
                    children: [
                      TitleBar(visible: visible,title: title,showArrow: showArrow,callback: (){
                        _goBack();
                      },),
                      Expanded(
                        child: WebView(
                          initialUrl: 'https://xyedu.app-yundian.xy100.cn/m/usercase-index',
                          onWebViewCreated: (WebViewController webviewController){
                            _webViewController = webviewController;
                          },
                          javascriptMode: JavascriptMode.unrestricted,
                          navigationDelegate: (NavigationRequest request) {
                            _webViewController.getTitle().then((value) => {
                              print("title:$value")
                            });
                            if(visible){
                              _webViewController.canGoBack().then((value){
                                setState(() {
                                  showArrow = value;
                                });
                              });
                            }
                            if (request.url.startsWith('js://webview')) {
                              print('blocking navigation to $request');
                              return NavigationDecision.prevent;
                            }
                            print('allowing navigation to $request');
                            return NavigationDecision.navigate;
                          },
                          onPageFinished: (String url) {
                            _webViewController.getTitle().then((value) =>
                            {
                              updateTitle(value)
                            });
                            if(visible){
                              _webViewController.canGoBack().then((value){
                                setState(() {
                                  showArrow = value;
                                });
                              });
                            }
                            print("onPageFinish:" + url);
                            ProgressDialog.dismiss(context);
                          },
                        ),
                      )
                    ],
                  );
                },),
                bottom: true,
                left: true,
                right: true,
                top: true,
              ),
            ),
          )
      ),
    );
  }
}

//标题显示
class TitleBar extends StatelessWidget{

  final bool visible;
  final String title;
  final _Callback callback;
  final bool showArrow; //箭头
  const TitleBar({Key key,this.visible,this.title,this.showArrow,this.callback}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: visible,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(10),bottom: ScreenUtil().setHeight(10)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child:InkWell(
                  child: Opacity(
                    child: Image.asset("assets/imgs/ic_arrow_left.png"),
                    opacity: showArrow ? 1.0 : 0,
                  ),
                  onTap: (){
                    if(showArrow){
                      callback();
                    }
                  },
                ),
                left: 10,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(40)
                ),
              )
            ],
          ),
        )
      ),
    );
  }

}

