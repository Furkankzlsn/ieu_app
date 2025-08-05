import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // Set UNUserNotificationCenter delegate
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      // Request notification permissions including badge
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
          print("Notification permissions granted including badge")
        } else {
          print("Notification permissions denied: \(error?.localizedDescription ?? "unknown error")")
        }
      }
    }
    
    // Set Messaging delegate
    Messaging.messaging().delegate = self
    
    // Register for remote notifications
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Set APNs token for Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Handle notifications when app is in foreground
  @available(iOS 10, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    print("=== iOS FOREGROUND NOTIFICATION ===")
    print("Notification will present: \(userInfo)")
    print("Title: \(notification.request.content.title)")
    print("Body: \(notification.request.content.body)")
    print("==================================")
    
    // Show notification even when app is in foreground
    completionHandler([[.alert, .sound, .badge]])
  }

  @available(iOS 10, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    print("=== NOTIFICATION TAPPED IN iOS ===")
    print("Title: \(response.notification.request.content.title)")
    print("🚫 iOS routing disabled - letting Flutter handle navigation")
    print("==========================")
    
    // Don't handle navigation here - let Flutter's FCM handle it
    // This prevents double navigation
    
    completionHandler()
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("=== FCM TOKEN UPDATED ===")
    print("FCM registration token: \(fcmToken ?? "nil")")
    print("========================")
    
    // FCM token updates will trigger Flutter DB service reinitialization
  }
}
