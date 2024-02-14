// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:ffi/ffi.dart';
import 'ffi_utils.dart';
import 'third_party/mediapipe/generated/mediapipe_common_bindings.dart'
    as bindings;

/// {@template TaskOptions}
/// {@endtemplate}
abstract class TaskOptions<T extends Struct> extends Equatable {
  /// {@macro TaskOptions}
  const TaskOptions();

  /// Converts this Dart [TaskOptions] instance into its associated
  /// C-represenation struct.
  Pointer<T> toStruct();

  /// Assigns all values to an existing struct.
  void assignToStruct(T struct);
}

/// Dart representation of MediaPipe's "BaseOptions" concept.
///
/// Used to configure various classifiers by specifying the model they will use
/// for computation.
///
/// See also:
///  * [MediaPipe's BaseOptions documentation](https://developers.google.com/mediapipe/api/solutions/java/com/google/mediapipe/tasks/core/BaseOptions)
///  * [ClassifierOptions], which is often used in conjunction to specify a
///    classifier's desired behavior.
class BaseOptions extends TaskOptions<bindings.BaseOptions> {
  /// Generative constructor that creates a [BaseOptions] instance.
  const BaseOptions._({
    this.modelAssetBuffer,
    this.modelAssetPath,
    required _BaseOptionsType type,
  })  : assert(
          !(modelAssetBuffer == null && modelAssetPath == null),
          'You must supply either `modelAssetBuffer` or `modelAssetPath`',
        ),
        assert(
          !(modelAssetBuffer != null && modelAssetPath != null),
          'You must only supply one of `modelAssetBuffer` and `modelAssetPath`',
        ),
        _type = type;

  /// Constructor for [BaseOptions] classes using a file system path.
  ///
  /// In practice, this is unsupported, as assets in Flutter are bundled into
  /// the build output and not available on disk. However, it can potentially
  /// be helpful for testing / development purposes.
  factory BaseOptions.path(String path) => BaseOptions._(
        modelAssetPath: path,
        type: _BaseOptionsType.path,
      );

  /// Constructor for [BaseOptions] classes using an in-memory pointer to the
  /// MediaPipe SDK.
  ///
  /// In practice, this is the only option supported for production builds.
  factory BaseOptions.memory(Uint8List buffer) {
    return BaseOptions._(
      modelAssetBuffer: buffer,
      type: _BaseOptionsType.memory,
    );
  }

  /// The model asset file contents as bytes;
  final Uint8List? modelAssetBuffer;

  /// Path to the model asset file.
  final String? modelAssetPath;

  final _BaseOptionsType _type;

  /// Converts this pure-Dart representation into C-memory suitable for the
  /// MediaPipe SDK to instantiate various classifiers.
  @override
  Pointer<bindings.BaseOptions> toStruct() {
    final ptr = calloc<bindings.BaseOptions>();
    assignToStruct(ptr.ref);
    return ptr;
  }

  @override
  void assignToStruct(bindings.BaseOptions struct) {
    switch (_type) {
      case _BaseOptionsType.path:
        {
          struct.model_asset_path = modelAssetPath!.copyToNative();
        }
      case _BaseOptionsType.memory:
        {
          struct.model_asset_buffer = modelAssetBuffer!.copyToNative();
          struct.model_asset_buffer_count = modelAssetBuffer!.lengthInBytes;
        }
    }
  }

  /// Releases all C memory held by this [bindings.BaseOptions] struct.
  static void freeStruct(bindings.BaseOptions struct) {
    if (struct.model_asset_path.isNotNullPointer) {
      calloc.free(struct.model_asset_path);
    }
    if (struct.model_asset_buffer.isNotNullPointer) {
      calloc.free(struct.model_asset_buffer);
    }
  }

  @override
  List<Object?> get props => [
        modelAssetBuffer,
        modelAssetPath,
        modelAssetBuffer?.lengthInBytes,
      ];
}

enum _BaseOptionsType { path, memory }

/// Dart representation of MediaPipe's "ClassifierOptions" concept.
///
/// Classifier options shared across MediaPipe classification tasks.
///
/// See also:
///  * [MediaPipe's ClassifierOptions documentation](https://developers.google.com/mediapipe/api/solutions/java/com/google/mediapipe/tasks/components/processors/ClassifierOptions)
///  * [BaseOptions], which is often used in conjunction to specify a
///    classifier's desired behavior.
class ClassifierOptions extends TaskOptions<bindings.ClassifierOptions> {
  /// Generative constructor that creates a [ClassifierOptions] instance.
  const ClassifierOptions({
    this.displayNamesLocale,
    this.maxResults,
    this.scoreThreshold,
    this.categoryAllowlist,
    this.categoryDenylist,
  });

  /// The locale to use for display names specified through the TFLite Model
  /// Metadata.
  final String? displayNamesLocale;

  /// The maximum number of top-scored classification results to return.
  final int? maxResults;

  /// If set, establishes a minimum `score` and leads to the rejection of any
  /// categories with lower `score` values.
  final double? scoreThreshold;

  /// Allowlist of category names.
  ///
  /// If non-empty, classification results whose category name is not in
  /// this set will be discarded. Duplicate or unknown category names
  /// are ignored. Mutually exclusive with `categoryDenylist`.
  final List<String>? categoryAllowlist;

  /// Denylist of category names.
  ///
  /// If non-empty, classification results whose category name is in this set
  /// will be discarded. Duplicate or unknown category names are ignored.
  /// Mutually exclusive with `categoryAllowList`.
  final List<String>? categoryDenylist;

  /// Converts this pure-Dart representation into C-memory suitable for the
  /// MediaPipe SDK to instantiate various classifiers.
  @override
  Pointer<bindings.ClassifierOptions> toStruct() {
    final ptr = calloc<bindings.ClassifierOptions>();
    assignToStruct(ptr.ref);
    return ptr;
  }

  @override
  void assignToStruct(bindings.ClassifierOptions struct) {
    _setDisplayNamesLocale(struct);
    _setMaxResults(struct);
    _setScoreThreshold(struct);
    _setAllowlist(struct);
    _setDenylist(struct);
  }

  void _setDisplayNamesLocale(bindings.ClassifierOptions struct) {
    if (displayNamesLocale != null) {
      struct.display_names_locale = displayNamesLocale!.copyToNative();
    }
  }

  void _setMaxResults(bindings.ClassifierOptions struct) {
    // This value must not be zero, and -1 implies no limit.
    struct.max_results = maxResults ?? -1;
  }

  void _setScoreThreshold(bindings.ClassifierOptions struct) {
    if (scoreThreshold != null) {
      struct.score_threshold = scoreThreshold!;
    }
  }

  void _setAllowlist(bindings.ClassifierOptions struct) {
    if (categoryAllowlist != null) {
      struct.category_allowlist = categoryAllowlist!.copyToNative();
      struct.category_allowlist_count = categoryAllowlist!.length;
    }
  }

  void _setDenylist(bindings.ClassifierOptions struct) {
    if (categoryDenylist != null) {
      struct.category_denylist = categoryDenylist!.copyToNative();
      struct.category_denylist_count = categoryDenylist!.length;
    }
  }

  /// Releases all C memory held by this [bindings.ClassifierOptions] struct.
  static void freeStruct(bindings.ClassifierOptions struct) {
    if (struct.display_names_locale.address != 0) {
      calloc.free(struct.display_names_locale);
    }
    if (struct.category_allowlist.address != 0) {
      calloc.free(struct.category_allowlist);
    }
    if (struct.category_denylist.address != 0) {
      calloc.free(struct.category_denylist);
    }
  }

  @override
  List<Object?> get props => [
        displayNamesLocale,
        maxResults,
        scoreThreshold,
        ...(categoryAllowlist ?? []),
        ...(categoryDenylist ?? []),
      ];
}

/// {@template EmbedderOptions}
/// Options for setting up an embedder.
///
/// See also:
///   [MediaPipe documentation](https://developers.google.com/mediapipe/api/solutions/java/com/google/mediapipe/tasks/text/textembedder/TextEmbedder.TextEmbedderOptions.Builder)
/// {@endtemplate}
class EmbedderOptions extends TaskOptions<bindings.EmbedderOptions> {
  /// {@macro EmbedderOptions}
  const EmbedderOptions({
    this.l2Normalize = false,
    this.quantize = false,
  });

  /// Whether to normalize the returned feature vector with L2 norm. Use this
  /// option only if the model does not already contain a native L2_NORMALIZATION
  /// TF Lite Op. In most cases, this is already the case and L2 norm is thus
  /// achieved through TF Lite inference.
  final bool l2Normalize;

  /// Whether the returned embedding should be quantized to bytes via scalar
  /// quantization. Embeddings are implicitly assumed to be unit-norm and
  /// therefore any dimension is guaranteed to have a value in [-1.0, 1.0]. Use
  /// the l2_normalize option if this is not the case.
  final bool quantize;

  /// Converts this pure-Dart representation into C-memory suitable for the
  /// MediaPipe SDK to instantiate various embedders.
  @override
  Pointer<bindings.EmbedderOptions> toStruct() {
    final ptr = calloc<bindings.EmbedderOptions>();
    assignToStruct(ptr.ref);
    return ptr;
  }

  @override
  void assignToStruct(bindings.EmbedderOptions struct) {
    struct.l2_normalize = l2Normalize;
    struct.quantize = quantize;
  }

  /// Releases all C memory held by this [bindings.EmbedderOptions] struct (of
  /// which there is none that will survive the freeing of the struct itself).
  static void freeStruct(bindings.EmbedderOptions struct) {
    // no-op; nothing to free
  }

  @override
  List<Object?> get props => [l2Normalize, quantize];
}
