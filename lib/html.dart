
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Html extends StatelessWidget{

  final String html;
  final String title;
  WebViewController _webViewController;

  Html({Key key,@required this.html,@required this.title}):super(key: key);


  /**
   * 异步加载本地assets中的html
   */
  _loadHtmlAssets() async{
    if(html == null){
      Fluttertoast.showToast(msg: "参数有错");
      return;
    }
    String content = await rootBundle.loadString(html);
    _webViewController.loadUrl(
      Uri.dataFromString(
        content,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
      ).toString()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(50),
                  color: Colors.black
                ),
              ),
              GestureDetector(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset("assets/imgs/ic_arrow_left.png",width: 20,height: 20,),
                ),
                onTap: (){
                  Navigator.pop(context);
                },
              )
            ],
          ),
          SizedBox(height: 10,),
          Expanded(
            child: WebView(
              onWebViewCreated: (WebViewController webViewController){
                this._webViewController = webViewController;
                _loadHtmlAssets();
              },
            ),
          )
        ],
      ),
    );
  }
}