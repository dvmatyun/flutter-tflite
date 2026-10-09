#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tflite_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tflite_flutter'
  s.version          = '0.0.1'
  s.summary          = 'TensorFlow Lite plugin for Flutter apps.'
  s.description      = <<-DESC
TensorFlow Lite plugin for Flutter apps.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  # s.source_files = 'Classes/**/*'
  
  s.dependency 'Flutter'
  
  tflite_version = '2.17.0'

  # TensorFlowLiteC, NOT TensorFlowLiteSwift.
  #
  # This is an FFI plugin: lib/src/bindings/bindings.dart resolves symbols with
  # `DynamicLibrary.process()` on iOS, i.e. against the C API that
  # TensorFlowLiteC links into the app. Nothing here compiles against the Swift
  # wrapper — ios/Classes/TfliteFlutterPlugin.swift imports only Flutter and
  # UIKit and implements nothing but `getPlatformVersion`.
  #
  # TensorFlowLiteC was already being pulled in transitively, because
  # TensorFlowLiteSwift/Core depends on it. Depending on it directly removes a
  # layer that was downloaded and never called.
  #
  # The practical reason: TensorFlowLiteSwift's podspec sources from
  #   { :git => "https://github.com/tensorflow/tensorflow.git",
  #     :commit => "ad6d8cc177d0c868982e39e0823d0efbfb95f04c" }
  # so `pod install` clones the entire TensorFlow monorepo to extract a few
  # .swift files. On any connection that cannot sustain a multi-GB fetch that
  # fails with
  #     error: RPC failed / fatal: early EOF
  #     fatal: fetch-pack: invalid index-pack output
  # TensorFlowLiteC is a ~50 MB prebuilt tarball from dl.google.com instead.
  #
  # Privacy manifests are preserved: each TensorFlowLiteC subspec ships its own
  # PrivacyInfo.xcprivacy inside its xcframework. The only manifest dropped is
  # the Swift wrapper's, which covered code no longer shipped.
  s.dependency 'TensorFlowLiteC', tflite_version
  s.dependency 'TensorFlowLiteC/Metal', tflite_version
  s.dependency 'TensorFlowLiteC/CoreML', tflite_version

  s.platform = :ios, '12.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
