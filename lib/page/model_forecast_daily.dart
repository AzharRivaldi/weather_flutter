class ModelForecastDaily {
  String? strTemp;
  String? strTempMin;
  String? strTempMax;
  String? strDesc;
  String? strDate;

  ModelForecastDaily({this.strTemp, this.strTempMin, this.strTempMax, this.strDesc,
      this.strDate});

  ModelForecastDaily.fromJson(Map<String, dynamic> json) {

        strTemp= (json['list'][0]['main']['temp']).round().toString();
        strTempMin= (json['list']['main']['temp_min']).round().toString();
        strTempMax= (json['list']['main']['temp_max']).round().toString();
        strDesc= json['list'][0];
        strDate= json['list']['dt_txt'].toString();

  }
  static List<ModelForecastDaily> fromJsonList(List list) {
    if (list.length == 0) return List<ModelForecastDaily>.empty();
    return list.map((item) => ModelForecastDaily.fromJson(item)).toList();
  }
}