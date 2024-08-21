import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:mediapipe_vision/third_party/mediapipe/mediapipe_vision_bindings.dart';

class PoseLandmarker {
  late ffi.Pointer<ffi.Void> _landmarker;
  ffi.Pointer<ffi.Pointer<ffi.Char>> _errorMsg = malloc<ffi.Pointer<ffi.Char>>();

  PoseLandmarker(PoseLandmarkerOptions options) {
    final optionsPointer = _allocatePoseLandmarkerOptions(options);

    _landmarker = pose_landmarker_create(optionsPointer, _errorMsg);
    if (_landmarker == ffi.nullptr) {
     // print("${_errorMsg.value.toDartString()}");
      throw Exception("Failed to create PoseLandmarker");
    }

    // Free allocated memory
    malloc.free(optionsPointer);
  }

  int detectImage(MpImage image, PoseLandmarkerResult result) {
    final imagePointer = _allocateMpImage(image);
    final resultPointer = _allocatePoseLandmarkerResult(result);

    int status = pose_landmarker_detect_image(_landmarker, imagePointer, resultPointer, _errorMsg);

    // Free allocated memory
    malloc.free(imagePointer);
    malloc.free(resultPointer);

    return status;
  }

  int detectForVideo(MpImage image, int timestamp, PoseLandmarkerResult result) {
    final imagePointer = _allocateMpImage(image);
    final resultPointer = _allocatePoseLandmarkerResult(result);

    int status = pose_landmarker_detect_for_video(_landmarker, imagePointer, timestamp, resultPointer, _errorMsg);

    // Free allocated memory
    malloc.free(imagePointer);
    malloc.free(resultPointer);

    return status;
  }

  int detectAsync(MpImage image, int timestamp) {
    final imagePointer = _allocateMpImage(image);

    int status = pose_landmarker_detect_async(_landmarker, imagePointer, timestamp, _errorMsg);

    // Free allocated memory
    malloc.free(imagePointer);

    return status;
  }

  void closeResult(PoseLandmarkerResult result) {
    final resultPointer = _allocatePoseLandmarkerResult(result);
    pose_landmarker_close_result(resultPointer);
    malloc.free(resultPointer);
  }

  void close() {
    pose_landmarker_close(_landmarker, _errorMsg);
    malloc.free(_errorMsg);
  }

  ffi.Pointer<PoseLandmarkerOptions> _allocatePoseLandmarkerOptions(PoseLandmarkerOptions options) {
    final pointer = malloc<PoseLandmarkerOptions>();
    pointer.ref
      ..base_options = options.base_options
      ..running_mode = options.running_mode
      ..num_poses = options.num_poses
      ..min_pose_detection_confidence = options.min_pose_detection_confidence
      ..min_pose_presence_confidence = options.min_pose_presence_confidence
      ..min_tracking_confidence = options.min_tracking_confidence
      ..output_segmentation_masks = options.output_segmentation_masks
      ..result_callback = options.result_callback;
    return pointer;
  }

  ffi.Pointer<MpImage> _allocateMpImage(MpImage image) {
    final pointer = malloc<MpImage>();
    pointer.ref
      ..type = image.type
      ..unnamed = image.unnamed;
    return pointer;
  }

  ffi.Pointer<PoseLandmarkerResult> _allocatePoseLandmarkerResult(PoseLandmarkerResult result) {
    final pointer = malloc<PoseLandmarkerResult>();
    pointer.ref
      ..segmentation_masks = result.segmentation_masks
      ..segmentation_masks_count = result.segmentation_masks_count
      ..pose_landmarks = result.pose_landmarks
      ..pose_landmarks_count = result.pose_landmarks_count
      ..pose_world_landmarks = result.pose_world_landmarks
      ..pose_world_landmarks_count = result.pose_world_landmarks_count;
    return pointer;
  }
}
