import UIKit
import Flutter
import NaverThirdPartyLogin
import flutter_naver_login

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

      NaverThirdPartyLoginConnection.getSharedInstance()?.isNaverAppOauthEnable = true
      NaverThirdPartyLoginConnection.getSharedInstance()?.isInAppOauthEnable = true

      let thirdConn = NaverThirdPartyLoginConnection.getSharedInstance()

      
      thirdConn?.serviceUrlScheme = "balbambalbamurlscheme"
      thirdConn?.consumerKey = "2y417ad5dnf4y2nohKSp"
      thirdConn?.consumerSecret = "97vwp_eTD3"
      thirdConn?.appName = "발밤발밤"

      // thirdConn?.setValue("balbambalbamurlscheme", forKey: "serviceUrlScheme")
      // thirdConn?.setValue("2y417ad5dnf4y2nohKSp", forKey: "consumerKey")
      // thirdConn?.setValue("97vwp_eTD3", forKey: "consumerSecret")
      // thirdConn?.setValue("발밤발밤", forKey: "appName")


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    var applicationResult = false
    if (!applicationResult) {
      applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
    }
    // if you use other application url process, please add code here.
    
    if (!applicationResult) {
      applicationResult = super.application(app, open: url, options: options)
    }
    return applicationResult
  }

  // override func application(
  //   _ app: UIApplication,
  //   open url: URL,
  //   options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  // ) -> Bool {
  //   if FlutterNaverLoginPlugin.application(app, open: url, options: options) {
  //     return true
  //   }
  //   return super.application(app, open: url, options: options)
  // }
}
