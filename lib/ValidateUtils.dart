/**
 * 验证码相关工具类
 */
class ValidateUtils{

  /**
   * 验证手机号是否正确
   */
  static String validatePhone(phone){
    //正则表达式匹配手机号
    RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    if(phone == null || phone.isEmpty){
      return "用户名或手机号不能为空";
    }else if(!exp.hasMatch(phone)){
      return "请输入正确的手机号";
    }
    return "";
  }

  /**
   * 密码校验
   */
  static String validatePassword(String pw){
    //数字
    RegExp numberExp = RegExp(r'/\d+/');
    //字母验证
    RegExp stringExp = RegExp(r'/[a-zA-Z]+/');
    if(pw.isEmpty){
      return "密码不能为空";
    }else if(pw.length < 6){
      return "密码长度不够";
    }
    /*else if(!numberExp.hasMatch(pw) || !stringExp.hasMatch(pw)){
      return "密码太简单";
    }*/
    return "";
  }

}