import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:mediapipe_vision/io.dart';
import 'package:mediapipe_vision/mediapipe_vision.dart';
import 'package:mediapipe_vision/mediapipe_vision.dart';
import 'package:mediapipe_vision/third_party/mediapipe/mediapipe_vision_bindings.dart';
import 'package:ffi/ffi.dart';

class PoseDetection extends StatefulWidget {
  @override
  _PoseDetectionState createState() => _PoseDetectionState();
}

class _PoseDetectionState extends State<PoseDetection> {
  late PoseLandmarker _poseLandmarker;
  String _resultMessage = "No result";

  @override
  void initState() {
    super.initState();
    _initializeLandmarker();
  }

  void _initializeLandmarker() {
    final options = calloc<PoseLandmarkerOptions>();
    try {
      options.ref
        // ..base_options = BaseOptions()
        ..running_mode = RunningMode.IMAGE
        ..num_poses = 1
        ..min_pose_detection_confidence = 0.5
        ..min_pose_presence_confidence = 0.5
        ..min_tracking_confidence = 0.5
        ..output_segmentation_masks = false
        ..result_callback = nullptr; // Adjust as needed

      _poseLandmarker = PoseLandmarker(options.ref);
    } finally {
      calloc.free(options);
    }
  }

  void _detectPose() {
    final image = calloc<MpImage>(); // Initialize your image
    final result = calloc<PoseLandmarkerResult>();

    try {
      int status = _poseLandmarker.detectImage(image.ref, result.ref);
      if (status == 0) {
        setState(() {
          _resultMessage = "Pose detection successful!";
        });
      } else {
        setState(() {
          _resultMessage = "Pose detection failed:";
        });
      }
    } finally {
      calloc.free(image);
      calloc.free(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pose Landmarker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_resultMessage),
            ElevatedButton(
              onPressed: _detectPose,
              child: Text('Detect Pose'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _poseLandmarker.close();
    super.dispose();
  }
}
