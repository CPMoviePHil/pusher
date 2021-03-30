class Values {
  static String server = '';
  static String serial = '';
  static String deviceToken = '';

  static final Values _values = Values.internal();

  factory Values() {
    return _values;
  }

  Values.internal();
}