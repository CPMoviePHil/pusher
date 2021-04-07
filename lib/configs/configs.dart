class Configs{

  static final String pushyUri = 'https://api.pushy.me/push?api_key=';
  static final String pushyKey = '65139183b78cf94017209edd9f7d2907bb3cd20708c7edc1c3a3e691532dd180';

  static final String uploadDeviceTokenApi = '/api/face/updataMachineDeviceToken';
  static final String fetchDeviceSeriesApi = '/api/face/indexMachineSerialNumber';

  static final Configs _configs = Configs._internal();

  factory Configs(){
    return _configs;
  }

  Configs._internal();
}