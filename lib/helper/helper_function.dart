import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  // keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  // save data to SP

  static Future<bool> saveUserLoggedInStatus(bool isLoggedIn) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setBool(userLoggedInKey, isLoggedIn);
  }

  static Future<bool> saveUserEmail(String email) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString(userEmailKey, email);
  }

  static Future<bool> saveUserName(String name) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString(userNameKey, name);
  }

  // get data from SP
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(userLoggedInKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userNameKey);
  }

  static Future<String?> getEmail() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userEmailKey);
  }

  static String getId(String res) {
    // fron index 0 to index of "_"
    return res.substring(0, res.indexOf("_"));
  }

  static String getName(String res) {
    // from (index of "_" +) 1  to the last
    return res.substring(res.indexOf("_") + 1);
  }
}
