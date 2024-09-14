class ModelWeather {
  String? strMain;
  String? strDesc;
  String? strWind;
  String? strHumidity;
  String? strTemp;

  ModelWeather({this.strMain, this.strDesc, this.strWind, this.strHumidity, this.strTemp});

  factory ModelWeather.fromJson(Map<String, dynamic> json) {
    return ModelWeather(
      strMain: json['weather'][0]['main'].toString(),
      strDesc: json['weather'][0]['description'].toString(),
      strWind: (json['wind']['speed']).round().toString(),
      strHumidity: json['main']['humidity'].toString(),
      strTemp: (json['main']['temp']).round().toString()
    );
  }

}