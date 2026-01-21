import Flutter
import UIKit
import apple_vision_recognize_text
import camera_avfoundation
import flutter_native_splash
import path_provider_foundation
import permission_handler_apple
import shared_preferences_foundation
import sqlite3_flutter_libs

// STUBS to satisfy GeneratedPluginRegistrant linking
@objc(GoogleMlKitCommonsPlugin)
class GoogleMlKitCommonsPlugin: NSObject {
    @objc static func register(with registrar: FlutterPluginRegistrar) {}
}

@objc(GoogleMlKitTextRecognitionPlugin)
class GoogleMlKitTextRecognitionPlugin: NSObject {
    @objc static func register(with registrar: FlutterPluginRegistrar) {}
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // GeneratedPluginRegistrant.register(with: self) // Disabled to exclude ML Kit

    // Manual Registration
    AppleVisionRecognizeTextPlugin.register(with: registrar(forPlugin: "AppleVisionRecognizeTextPlugin")!)
    CameraPlugin.register(with: registrar(forPlugin: "CameraPlugin")!)
    FlutterNativeSplashPlugin.register(with: registrar(forPlugin: "FlutterNativeSplashPlugin")!)
    PathProviderPlugin.register(with: registrar(forPlugin: "PathProviderPlugin")!)
    PermissionHandlerPlugin.register(with: registrar(forPlugin: "PermissionHandlerPlugin")!)
    SharedPreferencesPlugin.register(with: registrar(forPlugin: "SharedPreferencesPlugin")!)
    Sqlite3FlutterLibsPlugin.register(with: registrar(forPlugin: "Sqlite3FlutterLibsPlugin")!)
    
    // EXCLUDED:
    // GoogleMlKitTextRecognitionPlugin
    // GoogleMlKitCommonsPlugin

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
