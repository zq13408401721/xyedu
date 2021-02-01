import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class NetUtils{

  /**
   * 获取当前系统时间戳
   */
  static int currentTimeMillis(){
    return new DateTime.now().millisecondsSinceEpoch;
  }

  /**
   * 对参数进行md5hex
   */
  static String md5Hex(String param){
    return md5.convert(utf8.encode(param)).toString().toUpperCase();
  }
}