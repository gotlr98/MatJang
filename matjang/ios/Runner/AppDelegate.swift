import UIKit
import Flutter


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
      
    // let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
    // KakaoSDK.initSDK(appKey: kakaoAppKey as! String)


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
