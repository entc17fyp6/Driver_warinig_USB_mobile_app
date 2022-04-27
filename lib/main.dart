import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:test_1/model/traffic_light_model.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'ADAS system'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _lane_json_id = 0;
  int _last_lane_warning_time = DateTime.now().millisecondsSinceEpoch;
  double _lane_beta = 0;
  String _lane_departure_warning_text = "inside lanes";
  bool show_lane_departure_warning_img = false;

  int _traffic_json_id = 0;
  int _last_traffic_light_warning_time = DateTime.now().millisecondsSinceEpoch;
  var _old_traffic_light_id_list = <int>[];
  var _new_traffic_light_id_list = <int>[];
  String _traffic_light_warning_text = "no traffic lights nearby";
  bool show_traffic_light_img = false;

  Timer? refresh_timer;
  static const int refresh_time_period = 100; // milliseconds

  bool first_time = true;




  Future<int> traffic_light_sound() async {
    // print('something exciting is going to happen here...');
    await player.setAsset('assets/audio/traffic_light.mp3');
    player.play();
    return 1;
  }

  Future<int> left_lane_sound() async {
    // print('something exciting is going to happen here...');
    await player.setAsset('assets/audio/left_lane_departure.mp3');
    player.play();
    return 1;
  }

  Future<int> right_lane_sound() async {
    // print('something exciting is going to happen here...');
    await player.setAsset('assets/audio/right_lane_departure.mp3');
    player.play();
    return 1;
  }

  // Fetch content from the json file
  Future<void> readJson() async {
    String path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    File traffic_light_file = await File('$path/fyp/traffic_light_data.json');
    String traffic_light_contents = await traffic_light_file.readAsString();
    final traffic_light_data = await json.decode(traffic_light_contents);
    Traffic_lights traffic_lights = Traffic_lights.fromJson(traffic_light_data);

    File lane_file = await File('$path/fyp/lane_departure_data.json');
    String lane_contents = await lane_file.readAsString();
    final lane_data = await json.decode(lane_contents);
    // print(_counter);

    setState(() {
      // // int i = await
      // print('calling set state');
      // traffic light data
      if((_traffic_json_id != traffic_lights.json_id)){
        _traffic_json_id = traffic_lights.json_id;

        _new_traffic_light_id_list = List.from(traffic_lights.traffic_light_ids);

        if (!first_time){
          if ((DateTime.now().millisecondsSinceEpoch -_last_traffic_light_warning_time)>3000){
            if (_new_traffic_light_id_list.any((item) => _old_traffic_light_id_list.contains(item))) { // no sound warning
              _traffic_light_warning_text = "traffic lights detected ahead";   // show there are traffic lights without sound warnings
              show_traffic_light_img = true;
            }
            else{
              traffic_light_sound();
              _traffic_light_warning_text = "traffic lights detected ahead";
              show_traffic_light_img = true;

            }

            _last_traffic_light_warning_time = DateTime.now().millisecondsSinceEpoch;
            Timer traffic_light_show_timer = Timer(const Duration(seconds: 2), () { // show image and text for T seconds
              setState(() {
                show_traffic_light_img = false;
                _traffic_light_warning_text = "no traffic lights nearby";
              });
            });
          }

          _old_traffic_light_id_list = List.from(_new_traffic_light_id_list);
        }
      }

      // lane data
      if(_lane_json_id != lane_data["json_id"]){
        _lane_json_id = lane_data["json_id"];
        // _lane_beta = lane_data["beta"];


        if (!first_time){

          if ((DateTime.now().millisecondsSinceEpoch - _last_lane_warning_time) > 5000){  // stay silent for T seconds after once noticed

            _lane_beta = lane_data["beta"];

            if (_lane_beta>0){
              left_lane_sound();
              _lane_departure_warning_text = "left lane departure";
              show_lane_departure_warning_img = true;

            }
            else{
              right_lane_sound();
              _lane_departure_warning_text = "right lane departure";
              show_lane_departure_warning_img = true;
            }

            Timer lane_show_timer = Timer(const Duration(seconds: 2), () { // show image and text for T seconds
              setState(() {
                show_lane_departure_warning_img = false;
                _lane_departure_warning_text = "inside lanes";
              });
            });

          }
          _last_lane_warning_time = DateTime.now().millisecondsSinceEpoch;


        }

      }

      first_time = false;
    });
  }


  void requestPermission() {
    Permission.storage.request();
  }

  late AudioPlayer player;

  @override
  void initState() {
    requestPermission();
    refresh_timer = Timer.periodic(const Duration(milliseconds: refresh_time_period), (Timer t) => readJson());
    super.initState();
    player = AudioPlayer();
  }

  @override
  void dispose() {
    refresh_timer?.cancel();
    player.dispose();
    super.dispose();

  }
  // void _pushSaved() {
  //   Navigator.of(context).push(
  //     // Add lines from here...
  //     MaterialPageRoute<void>(
  //       builder: (context) {
  //         final tiles = _saved.map(
  //               (pair) {
  //             return ListTile(
  //               title: Text(
  //                 pair.asPascalCase,
  //                 style: _biggerFont,
  //               ),
  //             );
  //           },
  //         );
  //         final divided = tiles.isNotEmpty
  //             ? ListTile.divideTiles(
  //           context: context,
  //           tiles: tiles,
  //         ).toList()
  //             : <Widget>[];
  //
  //         return Scaffold(
  //           appBar: AppBar(
  //             title: const Text('Saved Suggestions'),
  //           ),
  //           body: ListView(children: divided),
  //         );
  //       },
  //     ), // ...to here.
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.list),
        //     // onPressed: _pushSaved,
        //     tooltip: 'Saved Suggestions',
        //   ),
        // ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            Text(_traffic_light_warning_text,
              style: const TextStyle(
              fontSize: 25,
              ),
            ),
            if (show_traffic_light_img)...[
              Image.asset(
                'assets/images/traffic_light.png',
                width: 200,
              ),
            ],
            Text(
                _lane_departure_warning_text,
              style: const TextStyle(
                  fontSize: 25,
              ),
            ),
            if(show_lane_departure_warning_img)...[
              if (_lane_beta > 0)...[
                Image.asset(
                  'assets/images/left_lane_departure.png',
                  width:200,
                ),
              ]
              else...[
               Image.asset(
                 'assets/images/right_lane_departure.png',
                 width: 200,
               ),
              ]
            ]
          ],
        )
        // child: (_new_traffic_light_json==true)? const Text('new traffic light'):const Text("no traffic lights"),
      ),
    );
  }
}