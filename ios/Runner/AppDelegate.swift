import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set up the method channel.
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let widgetChannel = FlutterMethodChannel(name: "com.debojyoti.year_progress/widget",
                                              binaryMessenger: controller.binaryMessenger)
    widgetChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // This method is invoked on the UI thread.
      guard call.method == "updateWidgetData" else {
        result(FlutterMethodNotImplemented)
        return
      }
        //reload timelines
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil) // Indicate success.
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
