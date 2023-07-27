class HpStr {
  // 存储Kb
  static double kb(String s) => s.codeUnits.length / 1024;

  /// 异或加密
  static String xor({required String k, required String s}) {
    late String result = '';
    if (k.isEmpty) {
      result = s;
    } else {
      result = '';
      for (int i = 0; i < s.length; i++) {
        int msgCode = s.codeUnitAt(i);
        int keyCode = k.codeUnitAt(i % k.length);
        var res = msgCode ^ keyCode;
        result += String.fromCharCode(res);
      }
    }
    return result;
  }
}
