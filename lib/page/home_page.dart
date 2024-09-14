import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:weather/page/model_weather.dart';
import 'package:weather/utils/tools.dart';

var formatter = DateFormat('EEE, dd MMM yyyy');
var date = DateTime.now();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String strLatLong = 'Belum Mendapatkan Lat dan Long, Silahkan tekan tombol';
  String strAlamat = 'Mencari lokasi...';
  String strDate = formatter.format(date);
  late String strIcon, strKet;
  double latitude = 0;
  double longitude = 0;
  List listDataForecast = [];
  List listDataForecastDaily = [];

  @override
  initState() {
    getData();
    super.initState();
    initializeDateFormatting();
  }

  Future getData() async {
    Position position = await getGeoLocationPosition();
    setState(() {
      strLatLong =
      '${position.latitude}, ${position.longitude}';
    });

    getAddressFromLongLat(position);
  }

  //getLatLong
  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    //location service not enabled, don't continue
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location service Not Enabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    //permission denied forever
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permission denied forever, we cannot access',
      );
    }

    //continue accessing the position of device
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //getAddress
  Future getAddressFromLongLat(Position position) async {
    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    print(placemarks);

    Placemark place = placemarks[0];
    setState(() {
      strAlamat = '${place.subAdministrativeArea}';
    });

    getWeather();
    getForecast();
    getForecastDaily();
  }

  Future getWeather() async {
    var url = Uri.parse('https://api.openweathermap.org/data/2.5/weather/?'
        'lat=$latitude&lon=$longitude&units=metric&APPID=API_KEY');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return ModelWeather.fromJson(data);
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  Future getForecast() async {
    var url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast/?'
        'lat=$latitude&lon=$longitude&units=metric&APPID=API_KEY');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        listDataForecast = data['list'];
      });
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  Future getForecastDaily() async {
    var url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast/daily/?'
        'lat=$latitude&lon=$longitude&units=metric&APPID=API_KEY');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        listDataForecastDaily = data['list'];
      });
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text(
              strAlamat,
              style: const TextStyle(
                  color: Colors.black
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            const Icon(
              Icons.location_on_rounded,
              color: Colors.black,
            ),
          ])
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: getWeather(),
              builder: (context, data) {
                if (data.hasError) {
                  return Center(
                      child: Text("${data.error}")
                  );
                } else if (data.hasData) {
                  var items = data.data as ModelWeather;

                  if (items.strDesc == "broken clouds") {
                    strIcon = 'assets/broken_clouds.json';
                    strKet = 'Tertutup Awan';
                  } else if (items.strDesc == "light rain") {
                    strIcon = 'assets/light_rain.json';
                    strKet = 'Gerimis';
                  } else if (items.strDesc == "haze") {
                    strIcon = 'assets/broken_clouds.json';
                    strKet = 'Berkabut';
                  } else if (items.strDesc == "overcast clouds") {
                    strIcon = 'assets/overcast_clouds.json';
                    strKet = 'Awan Mendung';
                  } else if (items.strDesc == "moderate rain") {
                    strIcon = 'assets/moderate_rain.json';
                    strKet = 'Hujan Ringan';
                  } else if (items.strDesc == "few clouds") {
                    strIcon = 'assets/few_clouds.json';
                    strKet = 'Berawan';
                  } else if (items.strDesc == "heavy intensity rain") {
                    strIcon = 'assets/heavy_intentsity.json';
                    strKet = 'Hujan Lebat';
                  } else if (items.strDesc == "clear sky") {
                    strIcon = 'assets/clear_sky.json';
                    strKet = 'Cerah';
                  } else if (items.strDesc == "scattered clouds") {
                    strIcon = 'assets/scattered_clouds.json';
                    strKet = 'Awan Tersebar';
                  }

                  return Card(
                    color: const Color(0xff6452f0),
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            '${items.strTemp}°C',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 60
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text(
                            strKet,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strDate,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Kecepatan Angin ${items.strWind} km/j',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Kelembaban ${items.strHumidity}%',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Lottie.asset(
                              strIcon,
                              width: 150,
                              height: 150,
                              fit: BoxFit.fill,
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  );
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: Text(
                "Next Hourly",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            SizedBox(
              height: 230,
              child: FutureBuilder(
                future: getForecast(),
                builder: (context, data) {
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: listDataForecast.length,
                      itemBuilder: (context, index) {
                        var items = listDataForecast[index]['weather'][0]['description'];

                        if (items == "broken clouds") {
                          strIcon = 'assets/broken_clouds.json';
                          strKet = 'Tertutup Awan';
                        } else if (items == "light rain") {
                          strIcon = 'assets/light_rain.json';
                          strKet = 'Gerimis';
                        } else if (items == "haze") {
                          strIcon = 'assets/broken_clouds.json';
                          strKet = 'Berkabut';
                        } else if (items == "overcast clouds") {
                          strIcon = 'assets/overcast_clouds.json';
                          strKet = 'Awan Mendung';
                        } else if (items == "moderate rain") {
                          strIcon = 'assets/moderate_rain.json';
                          strKet = 'Hujan Ringan';
                        } else if (items == "few clouds") {
                          strIcon = 'assets/few_clouds.json';
                          strKet = 'Berawan';
                        } else if (items == "heavy intensity rain") {
                          strIcon = 'assets/heavy_intentsity.json';
                          strKet = 'Hujan Lebat';
                        } else if (items == "clear sky") {
                          strIcon = 'assets/clear_sky.json';
                          strKet = 'Cerah';
                        } else if (items == "scattered clouds") {
                          strIcon = 'assets/scattered_clouds.json';
                          strKet = 'Awan Tersebar';
                        }

                        return Card(
                          margin: const EdgeInsets.all(10),
                          clipBehavior: Clip.antiAlias,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          color: const Color(0xff6452f0),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(SetTime.setTime(listDataForecast[index]['dt_txt'].toString()),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Lottie.asset(
                                  strIcon,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.fill,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text('${num.parse(listDataForecast[index]['main']['temp'].toString()).toStringAsFixed(0)}°C',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14
                                    )
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: Colors.white,
                                        ),
                                        Text('${num.parse(listDataForecast[index]['main']['temp_min'].toString()).toStringAsFixed(0)}°C',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14)
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                        ),
                                        Text('${num.parse(listDataForecast[index]['main']['temp_max'].toString()).toStringAsFixed(0)}°C',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14)
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            isDismissible: false,
            enableDrag: false,
            context: context,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20)
                )
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "View Data",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Chirp',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            iconSize: 30,
                            icon: const Icon(Icons.clear),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    ),
                    FutureBuilder(
                      future: getForecastDaily(),
                      builder: (context, data) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listDataForecastDaily.length,
                            itemBuilder: (context, index) {
                              var items = listDataForecastDaily[index]['weather'][0]['description'];

                              if (items == "broken clouds") {
                                strIcon = 'assets/broken_clouds.json';
                                strKet = 'Tertutup Awan';
                              } else if (items == "light rain") {
                                strIcon = 'assets/light_rain.json';
                                strKet = 'Gerimis';
                              } else if (items == "haze") {
                                strIcon = 'assets/broken_clouds.json';
                                strKet = 'Berkabut';
                              } else if (items == "overcast clouds") {
                                strIcon = 'assets/overcast_clouds.json';
                                strKet = 'Awan Mendung';
                              } else if (items == "moderate rain") {
                                strIcon = 'assets/moderate_rain.json';
                                strKet = 'Hujan Ringan';
                              } else if (items == "few clouds") {
                                strIcon = 'assets/few_clouds.json';
                                strKet = 'Berawan';
                              } else if (items == "heavy intensity rain") {
                                strIcon = 'assets/heavy_intentsity.json';
                                strKet = 'Hujan Lebat';
                              } else if (items == "clear sky") {
                                strIcon = 'assets/clear_sky.json';
                                strKet = 'Cerah';
                              } else if (items == "scattered clouds") {
                                strIcon = 'assets/scattered_clouds.json';
                                strKet = 'Awan Tersebar';
                              }

                              int strLongDate = listDataForecastDaily[index]['dt'];

                              return Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                                          child: Text(readTimestamp(strLongDate),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Lottie.asset(
                                          strIcon,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.fill,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons.keyboard_arrow_up,
                                                  color: Colors.black,
                                                ),
                                                Text('${num.parse(listDataForecastDaily[index]['temp']['min'].toString()).toStringAsFixed(0)}°C',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14)
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 14,
                                            ),
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.black,
                                                ),
                                                Text('${num.parse(listDataForecastDaily[index]['temp']['max'].toString()).toStringAsFixed(0)}°C',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14)
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: const Color(0xff6452f0),
        label: const Text('Next 15 Days'),
        icon: const Icon(Icons.next_plan_outlined),
      ),
    );
  }

}