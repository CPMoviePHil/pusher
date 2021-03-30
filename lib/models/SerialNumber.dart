class SerialNumber {
  String serialNumber;

  SerialNumber({this.serialNumber});

  SerialNumber.fromJson(Map<String, dynamic> json) {
    serialNumber = json['serial_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serial_number'] = this.serialNumber;
    return data;
  }
}
