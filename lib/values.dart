class Values {
  static String appVersion = '1.0.5';
  static String server;
  static String serial;
  static String deviceToken;
  static bool ttsSetting;
  static bool waiting;

  static final Values _values = Values._internal();

  factory Values() {
    return _values;
  }

  Values._internal();
}