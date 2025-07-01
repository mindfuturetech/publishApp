import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import './secrets.dart';
import './additional_info_item.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather;

  Future<Map<String,dynamic>> getCurrentWeather() async{
    try{
      String cityName='Singapore';
      final res=await http.get(
          Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeatherAPIkey')
      );
      final data = jsonDecode(res.body);
      if(data['cod'] == '201'){
        throw "UnExpected error Occurred";
      }

      // temp=data['list'][0]['main']['temp'];
      return data;


    }catch(e){
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather=getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF1D1E33),
      appBar:AppBar(
        centerTitle: true,
        title: const Text("Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(onPressed:(){
            setState(() {
              weather=getCurrentWeather();
            });
          },
              icon: Icon(Icons.refresh,size: 28,color: Colors.blueAccent,)
          )

        ],
      ),

      body: FutureBuilder(
        future: getCurrentWeather(),
        builder:(context,snapshots) {
          //Handling ERRORS in Snapshot
          if(snapshots.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshots.hasError){
            return Center(child: Text(snapshots.error.toString()));
          }

          final data=snapshots.data!;
          final currentWeatherData=data['list'][0];
          final currentTemperature=currentWeatherData['main']['temp'];
          final currentSky=currentWeatherData['weather'][0]['main'];
          final currentHumidity=currentWeatherData['main']['humidity'];
          final currentPressure=currentWeatherData['main']['pressure'];
          final currentSpeed=currentWeatherData['wind']['speed'];

          return Padding(
                padding:EdgeInsets.all(16.0) ,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //main Card
                    SizedBox(
                        width: double.infinity,
                        height: 200,
                        child:Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                          ),
                          elevation: 10,
                          color: Color(0xFF1D1E33),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX:2,sigmaY: 2),
                              child:Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Text('$currentTemperature K',
                                      style:TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:32.0,
                                        color: Colors.white

                                      ) ,
                                    ),
                                    Icon(
                                      currentSky=="Rain" || currentSky=="Clouds"
                                          ? Icons.cloud
                                          :Icons.sunny,
                                      size: 64,
                                      color: Colors.yellowAccent,
                                    ),
                                    Text(currentSky,
                                      style:TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ) ,
                                    )

                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                    ),


                    //weather forecast card
                    const SizedBox(height: 20),
                    const Text("Hourly Forecast",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:FontWeight.bold,
                     ),
                    ),
                    const SizedBox(height: 16,),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       for(int i=0;i<5;i++)
                    //         HourlyForecastItem(
                    //           time: data['list'][i+1]['dt'].toString(),
                    //           icon: data['list'][i+1]['weather'][0]['main']=="Clouds" || data['list'][i+1]['weather'][0]['main']=="Rain" ? Icons.cloud : Icons.sunny,
                    //           temperature: data['list'][i+1]['main']['temp'].toString(),
                    //         ),
                    //
                    //   ],
                    // ),
                    // ),
                    
                    SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:5 ,
                        itemBuilder: (context,index){
                          final hourlyForecast=data['list'][index+1];
                          final hourlySky=data['list'][index+1]['weather'][0]['main'];
                          final time=DateTime.parse( hourlyForecast['dt_txt'].toString());
                          return HourlyForecastItem(
                            time:DateFormat.jm().format(time),
                            icon: hourlySky=="Clouds" || hourlySky=="Rain"
                                ? Icons.cloud
                                : Icons.sunny,
                            temperature: hourlyForecast['main']['temp'].toString(),
                          );
                        },
                      ),
                    ),

                    //last part
                    const SizedBox(height: 16,),
                    const Text("Additional Information",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: '$currentHumidity',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: '$currentSpeed',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.beach_access,
                          label: 'Pressure',
                          value: '$currentPressure',
                        ),
                      ],
                    )

                  ],
                ),
              );
        },
      )
    );
  }
}



