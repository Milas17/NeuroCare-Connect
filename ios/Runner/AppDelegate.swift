import UIKit
import Flutter
import GoogleMaps
import Firebase
import FirebaseCore
import FirebaseFirestore
import flutter_local_notifications
import FirebaseAuth
import CallKit
import AVFoundation
@main
@objc class AppDelegate: FlutterAppDelegate,MessagingDelegate {
   let callController = CXCallController()
    var provider: CXProvider?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDz1y0fB0muduJwK0cwA2nUlVJP15CNaIU")
    FirebaseConfiguration.shared.setLoggerLevel(FirebaseLoggerLevel.min)
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    
   // Local Notification Start
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
    GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: self)
    // if #available(iOS 10.0, *) {
    //     UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    //     let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    //     UNUserNotificationCenter.current().requestAuthorization(
    //             options: authOptions,
    //             completionHandler: {_, _ in })
    // } else {
    //     let settings: UIUserNotificationSettings =
    //     UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    //     application.registerUserNotificationSettings(settings)
    // }
    // application.registerForRemoteNotifications()
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    let channel = FlutterMethodChannel(name: "callkit_channel", binaryMessenger: controller.binaryMessenger)

        let config = CXProviderConfiguration(localizedName: "yourappname")
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.generic]
        provider = CXProvider(configuration: config)

        channel.setMethodCallHandler { (call, result) in
            if call.method == "configureAudioSession" {
                self.configureAudioSession()
                result(nil)
            } else if call.method == "endCall" {
                self.endCall()
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .videoChat, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
            print("AudioSession configured for video call")
        } catch {
            print("AudioSession error: \(error)")
        }
    }

    func endCall() {
        let endAction = CXEndCallAction(call: UUID())
        let transaction = CXTransaction(action: endAction)
        callController.request(transaction) { error in
            if let err = error {
                print("Error ending call: \(err.localizedDescription)")
            }
        }
    }
    override func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert) // shows banner even if app is in foreground
    }

    
}
