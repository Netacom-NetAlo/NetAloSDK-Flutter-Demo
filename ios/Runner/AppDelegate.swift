import UIKit
import Flutter
import NetAloFull
import NetAloLite
import XCoordinator
import NATheme
import RxCocoa
import RxSwift
import NADomain

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var currentResult:FlutterResult?
    
    //SDK V2
    public var netAloFull: NetAloFullManager!
    private var disposeBag = DisposeBag()
    private lazy var mainWindow = UIWindow(frame: UIScreen.main.bounds)
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.netAloFull = NetAloFullManager(config: BuildConfig.config)
        
        // Only show SDK after start success, Waiting maximun 10s
        self.netAloFull
            .start()
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .catchAndReturn(())
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .do(onNext: { (owner, _) in
                // Init rooter
                owner.netAloFull.buildSDKModule()
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        onReceiveChannel()
        GeneratedPluginRegistrant.register(with: self)
                
        // Optional use notification
        self.netAloFull.requestNotificationtPermission()
        UNUserNotificationCenter.current().delegate = self
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    func onReceiveChannel(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        MethodChannel.instance.initChannel(messenger: controller.binaryMessenger)
        
        MethodChannel.instance.receiveChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.currentResult = result
            switch (call.method){
            case "setSdkUser":
                self.setNetaloUser(call: call,result: result)
            case "openCallWithUser":
                self.openCallWithUser(call: call,result: result)
            case "openChatWithUser":
                self.openChatWithUser(call: call, result: result)
            case "openListConversation":
                self.openChatConversation(result: result)
            case "logoutSDK":
                self.logoutSDK(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    private func openCallWithUser(call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let args = call.arguments,
              let myArgs = args as? [String: Any]
        else {
            result(false)
            return
        }
        
        let id = myArgs["id"] as? Int64 ?? 0
        let phoneNumber = myArgs["phone"] as? String ?? ""
        let fullName = myArgs["username"] as? String ?? ""
        let avatar = myArgs["avatar"] as? String ?? ""
        
        let contact = NAContact(id: id,
                                phone: phoneNumber,
                                fullName: fullName,
                                profileUrl: avatar)
        self.netAloFull.showCall(with: contact, isVideoCall: false) { err in
            result(true)
        }
    }
    
    private func openChatConversation(result: FlutterResult?) -> Void {
        self.netAloFull.showListGroup { err in
            result?(true)
        }
    }
    
    private func openChatWithUser(call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let args = call.arguments,
              let myArgs = args as? [String: Any]
        else {
            result(false)
            return
        }
        
        let id = myArgs["id"] as? Int64 ?? 0
        let phoneNumber = myArgs["phone"] as? String ?? ""
        let fullName = myArgs["username"] as? String ?? ""
        let avatar = myArgs["avatar"] as? String ?? ""
        
        let contact = NAContact(id: id,
                                phone: phoneNumber,
                                fullName: fullName,
                                profileUrl: avatar)
        self.netAloFull.showChat(with: contact) { err in
            result(true)
        }
    }
    
    private func setNetaloUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments,
              let myArgs = args as? [String: Any],
              let id = myArgs["id"] as? Int64
        else {
            result(false)
            return
        }
        
        let phoneNumber = myArgs["phone"] as? String ?? ""
        let fullName = myArgs["username"] as? String ?? ""
        let avatar = myArgs["avatar"] as? String ?? ""
        let token = myArgs["token"] as? String ?? ""
        
        //Set user
        let user = NetAloUserHolder(id: id,
                                    phoneNumber: phoneNumber,
                                    email: "",
                                    fullName: fullName,
                                    avatarUrl: avatar,
                                    session: token)
        dump("myLog user 💪💪💪 \(user)")
        do {
            try self.netAloFull.set(user: user)
        } catch let e {
            print("Error \(e)")
        }

        self.bindingService()
        
        result(true)
    }
    
    private func logoutSDK(result: @escaping FlutterResult) {
        self.netAloFull.logout()
        result(true)
    }
    
}


extension AppDelegate {
    // MARK: - AppDelegateViewModelOutputs
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        self.netAloFull.applicationDidBecomeActive(application)
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        self.netAloFull.applicationWillResignActive(application)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        self.netAloFull.applicationWillTerminate(application)
    }

    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if self.netAloFull != nil {
            return self.netAloFull.application(application, supportedInterfaceOrientationsFor: window)
        }
        return .portrait
    }

    // UserActivity
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        self.netAloFull.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    //MARK: - NOTIFICATION
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.netAloFull.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        self.netAloFull.application(application, open: url, sourceApplication: sourceApplication, annotation: application)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.netAloFull.application(app, open: url, options: options)
    }
    
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)

        self.netAloFull.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }

    public override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)

        self.netAloFull.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
}

//MARK: SDK callback and send event to Client
extension AppDelegate {
    //SDK binding service
    private func bindingService() {
        self.netAloFull.eventObservable
            .asDriverOnErrorJustSkip()
            .drive(onNext: { [weak self] event in
                dump("Event 🤟🏻🤟🏻🤟🏻🤟🏻🤟🏻🤟🏻 \(event)")
                switch event {
                case .mediaURL(let imageUrls, let videoUrls):
                    dump("Images 💪💪💪: \(imageUrls)")
                    dump("Video 💪💪💪: \(videoUrls)")
                case .checkUserIsFriend(let userId):
                    dump("Check Chat with 💪💪💪 : \(userId)")
                case .didCloseSDK:
                    dump("didCloseSDK 💪💪💪")
                case .pressedCall(let type):
                    dump("pressedCall 💪💪💪 type \(type)")
                case .socketError(let error):
                    switch error {
                    case .expired:
                        dump("socketError 💪💪💪 \(error.description)")
                    default:
                        dump("socketError 💪💪💪 \(error.description)")
                    }
                case .updateBadge(let badge):
                    dump("updateBadge 💪💪💪 \(badge)")
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
}
