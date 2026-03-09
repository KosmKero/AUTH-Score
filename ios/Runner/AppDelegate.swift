

import Flutter
import UIKit
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1. Καταγράφουμε τα plugins ΠΡΙΝ το super.application
    GeneratedPluginRegistrant.register(with: self)


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}