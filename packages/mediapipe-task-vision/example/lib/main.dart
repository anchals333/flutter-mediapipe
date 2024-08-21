import 'dart:ffi';
import 'package:example/pose_detection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mediapipe_vision/io.dart';
import 'package:mediapipe_vision/mediapipe_vision.dart';
import 'package:mediapipe_vision/mediapipe_vision.dart';
import 'package:mediapipe_vision/third_party/mediapipe/mediapipe_vision_bindings.dart';
import 'package:ffi/ffi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Landmarker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Pose Detection"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) {
              return PoseDetection();
            }));
          },
          child: Icon(Icons.add),
        ),
        body: Center(
          child: Text("Click on fab for pose detection"),
        ));
  }
}
