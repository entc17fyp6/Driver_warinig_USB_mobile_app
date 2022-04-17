import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  bool _new_lane_json = false;
  int _new_lane_json_time = 0;
  double _lane_beta = 0;
  int _traffic_json_id = 0;
  bool _new_traffic_light_json = false;
  int _new_traffic_light_json_time = 0;
  Timer? refresh_timer;

  // Fetch content from the json file
  Future<void> readJson() async {
    String path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    File traffic_light_file = await File('$path/fyp/traffic_light_data.json');
    String traffic_light_contents = await traffic_light_file.readAsString();
    final traffic_light_data = await json.decode(traffic_light_contents);

    File lane_file = await File('$path/fyp/lane_departure_data.json');
    String lane_contents = await lane_file.readAsString();
    final lane_data = await json.decode(lane_contents);
    // print(_counter);
    setState(() {


      // traffic light data
      if(_traffic_json_id != traffic_light_data["json_id"]){
        _traffic_json_id = traffic_light_data["json_id"];
        _new_traffic_light_json = true;
        _new_traffic_light_json_time = DateTime.now().millisecondsSinceEpoch;
      }
      else{
        // print(DateTime.now().millisecondsSinceEpoch - _new_json_time);
        if((DateTime.now().millisecondsSinceEpoch - _new_traffic_light_json_time)<1000){
          _new_traffic_light_json = true;
        }
        else{
          _new_traffic_light_json = false;
        }
      }

      // lane data
      if(_lane_json_id != lane_data["json_id"]){
        _lane_json_id = lane_data["json_id"];
        _lane_beta = lane_data["beta"];

        _new_lane_json = true;
        _new_lane_json_time = DateTime.now().millisecondsSinceEpoch;
      }
      else{
        // print(DateTime.now().millisecondsSinceEpoch - _new_json_time);
        if((DateTime.now().millisecondsSinceEpoch - _new_lane_json_time)<1000){
          _new_lane_json = true;
        }
        else{
          _new_lane_json = false;
        }
      }
    });
  }


  void requestPermission() {
    Permission.storage.request();
  }

  @override
  void initState() {
    requestPermission();
    refresh_timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) => readJson());
    super.initState();
  }

  @override
  void dispose() {
    refresh_timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            (_new_traffic_light_json==true)? const Text('new traffic light ****'):const Text("no traffic lights"),
            (_new_lane_json==true)? ((_lane_beta > 0)? const Text('left lane departure'):const Text('right lane departure')):const Text("inside lane"),
          ],
        )
        // child: (_new_traffic_light_json==true)? const Text('new traffic light'):const Text("no traffic lights"),
      ),

      // body: Padding(
      //   padding: const EdgeInsets.all(25),
      //   child: Column(
      //     children: [
      //       ElevatedButton(
      //         child: const Text('Load Data'),
      //         onPressed: readJson,
      //       ),
      //
      //       // Display the data loaded from sample.json
      //       _new_json == true
      //           ? Expanded(
      //         child: ListView.builder(
      //           itemCount: _items.length,
      //           itemBuilder: (context, index) {
      //             return Card(
      //               margin: const EdgeInsets.all(10),
      //               child: ListTile(
      //                 leading: Text(_items[index]["id"]),
      //                 title: Text(_items[index]["name"]),
      //                 subtitle: Text(_items[index]["description"]),
      //               ),
      //             );
      //           },
      //         ),
      //       )
      //           : Container()
      //     ],
      //   ),
      // ),
      //
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _fetchData,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}