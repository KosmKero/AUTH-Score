import UIKit
import Flutter
import FirebaseCore // Προσθήκη

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ΠΡΟΣΘΗΚΗ: Αρχικοποιούμε το Firebase στο Native επίπεδο ΠΡΙΝ τα plugins
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}