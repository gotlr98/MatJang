import UIKit
import Flutter
//import kakao_flutter_sdk_common

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // if (CLLocationManager.locationServicesEnabled()) {
    // switch CLLocationManager.authorizationStatus() {
    // case .denied, .notDetermined, .restricted:
    //     self.manager.requestAlwaysAuthorization()
    //     break
    // default:
    //     break
    // }
      
//     let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
//     KakaoSDK.initSDK(appKey: kakaoAppKey as! String)


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
//    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//            if url.absoluteString.hasPrefix("kakao"){
//                super.application(app, open:url, options: options)
//                return true
//            } else if url.absoluteString.contains("thirdPartyLoginResult") {
//                NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
//                return true
//            } else {
//                return true
//            }
//        }
}
