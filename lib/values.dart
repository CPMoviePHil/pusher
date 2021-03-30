class Values {
  static String server;
  static String serial;
  static String deviceToken;
  static bool ttsSetting;

  static final Values _values = Values._internal();

  factory Values() {
    return _values;
  }

  Values._internal();
}