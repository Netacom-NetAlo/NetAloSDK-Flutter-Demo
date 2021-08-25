import UIKit
import Flutter
import NetaloUISDK
import SwipeTransition

struct NetAloSDKConfig {
    let env: NetaloEnviroment
    let appId: Int64
    let appKey: String
    let accountKey: String
    let appGroupIdentifier: String
    
    static let dev = NetAloSDKConfig(env: .testing, appId: 14, appKey: "87XuVRwP71uljnlK3pdxKhWTvPQEXCJC", accountKey: "87XuVRwP71uljnlK3pdxKhWTvPQEXCJC", appGroupIdentifier: "group.vn.netacom.netalo-dev")
    static let prod = NetAloSDKConfig(env: .production, appId: 14, appKey: "87XuVRwP71uljnlK3pdxKhWTvPQEXCJC", accountKey: "87XuVRwP71uljnlK3pdxKhWTvPQEXCJC", appGroupIdentifier: "group.vn.netacom.netalo-dev")
}


class UserHolder: NetaloUser {
    
    var id: Int64
    var phoneNumber: String
    var email: String
    var fullName: String
    var avatarUrl: String
    var session: String
    var canCreateGroup: Bool
    
    //HardCode for testing
    init() {
        self.id = 2814749770541045
        self.phoneNumber = "+84123456789"
        self.email = "lomotest@gmail.com"
        self.fullName = "LOMO AC"
        self.avatarUrl = "FCdgiUzoSLZrxfo4ceDGHgJLKvUU-zSM7lSMwa3c3FbpJcgOuDyiSzFtHEr_AlUv"
        self.session = "5428c0502217505bc5dcdc968ccbfed43fb0c896"
        self.canCreateGroup = false
    }
    
    init(id: Int64,
         phoneNumber: String,
         email: String,
         fullName: String,
         avatarUrl: String,
         session: String,
         canCreateGroup: Bool = false) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.email = email
        self.fullName = fullName
        self.avatarUrl = avatarUrl
        self.session = session
        self.canCreateGroup = canCreateGroup
    }
}


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // NetaloUISDK
    var netAloSDKEnvironment = NetAloSDKConfig.dev
    var userDemo: UserHolder?
    var currentVC: UIViewController?
    
    private lazy var netaloSDK: NetaloUISDK = {
        var authorizationType = AuthorizationType.phoneNumber("")
        if let user = NetaloUISDK.authorizedUser() {
            authorizationType = AuthorizationType.user(user)
        }
        
        let config = NetaloConfiguration(
            authorizationType: authorizationType,
            enviroment: netAloSDKEnvironment.env,
            appId: netAloSDKEnvironment.appId,
            appKey: netAloSDKEnvironment.appKey,
            accountKey: netAloSDKEnvironment.accountKey,
            appGroupIdentifier: netAloSDKEnvironment.appGroupIdentifier,
            analytics: [],
            featureConfig: FeatureConfig(
                user: FeatureConfig.UserConfig(
                    forceUpdateProfile: true,
                    forceUpdateUserProfileUrl: true,
                    allowCustomUserName: true,
                    allowFetchWithFullUserInfo: true,
                    allowCustomProfile: true,
                    allowCustomAlert: true
                ),
                chat: FeatureConfig.ChatConfig(isVideoCallEnable: false, isVoiceCallEnable: false),
                isSyncDataOnFirstLogin: true,
                allowCustomStatusBarStyle: false,
                reserverWebDomain: "example.vn"
            )
        )
        
        return NetaloUISDK(config: config)
    }()
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        MethodChannel.instance.initChannel(messenger: controller.binaryMessenger)
        
        MethodChannel.instance.receiveChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch (call.method){
            case "openChatConversation":
                //                self.openImagePicker()
                self.openChatConversation(result: result)
            case "initNetAloSDK":
                //self.setNetaloUser(call: call, result: result)
                result(true)
                XLog.print("initNetAloSDK")
            case "openChatWithUser":
                self.openChatWithUser(call:call,result: result)
            case "setNetaloUser":
                self.setNetaloUser(call: call,result: result)
                self.registerRemoteToken()
            case "setEnvironmentNetAloSdk":
                let env = call.arguments as! String
                self.setEnviroment(env,result: result)
                //                self.checkIsFriend(netAloId: 562949954405553)
                result(true)
                XLog.print("setEnvironmentNetAloSdk")
            case "pickImages":
                self.openImagePicker(call: call,result: result)
            case "blockUser":
                self.blockUser(call: call,result: result)
            case "unBlockUser":
                self.unBlockUser(call: call,result: result)
            case "setDomainLoadAvatarNetAloSdk":
                self.setImageDomain(call: call, result: result)
            case "sendMessage" :
                self.sendMessage(call: call, result: result)
            case "closeNetAloChat":
                self.closeSDK()
            case "checkGroupChatExist":
                self.checkGroupChatExist(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        
        //Init NetaloUISDK
        netaloSDK.add(delegate: self)
        let _ = netaloSDK.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func checkGroupChatExist(call: FlutterMethodCall,result: @escaping FlutterResult){
        guard let args = call.arguments else {
            return
        }
        
        let userId = args as? Int64 ?? 0
        //todo check sdk
        self.netaloSDK.checkChatted(with: String(userId)) { (isChatted) in
            result(isChatted)
            XLog.print(isChatted)
        }
    }
    
    func sendMessage(call: FlutterMethodCall,result: @escaping FlutterResult){
        guard let args = call.arguments else {
            return
        }
        
        let myArgs = args as! [String: Any]
        
        let message  = myArgs["message"] as? String ?? ""
        let receiver = myArgs["receiver"] as? [String: Any]
        let receiverId = receiver?["id"] as? Int64 ?? 0
        self.netaloSDK.sendMessage(text: message, to: String(receiverId)) { (success) in
            XLog.print(success)
            result(success)
        }
    }
    
    func openChatConversation(result: FlutterResult?) -> Void {
        // TODO NATIVE HERE
        //Add Netalo in ContainView
        let vc = ContainNetaloViewController.instantiate(sdk: self.netaloSDK)
        vc.modalPresentationStyle = .fullScreen
        
        //option nav
        let nav = SwipeBackNavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(nav, animated: true, completion: nil)
        
        currentVC = nav
        result?(true)
    }
    
    private func setEnviroment(_ env: String,result: @escaping FlutterResult) {
        
        let netAloConfig = env == "pro" ? NetAloSDKConfig.prod : NetAloSDKConfig.dev
        var authorizationType = AuthorizationType.phoneNumber("")
        if let user = NetaloUISDK.authorizedUser() {
            authorizationType = AuthorizationType.user(user)
        }
        
        let config = NetaloConfiguration(
            authorizationType: authorizationType,
            enviroment: netAloConfig.env,
            appId: netAloConfig.appId,
            appKey: netAloConfig.appKey,
            accountKey: netAloConfig.accountKey,
            appGroupIdentifier: netAloConfig.appGroupIdentifier,
            analytics: [],
            featureConfig: FeatureConfig(
                user: FeatureConfig.UserConfig(
                    forceUpdateProfile: true,
                    forceUpdateUserProfileUrl: true,
                    allowCustomUserName: true,
                    allowFetchWithFullUserInfo: true,
                    allowCustomProfile: true,
                    allowCustomAlert: true
                ),
                chat: FeatureConfig.ChatConfig(isVideoCallEnable: false, isVoiceCallEnable: false),
                isSyncDataOnFirstLogin: true,
                allowCustomStatusBarStyle: false,
                reserverWebDomain: "example.vn"
            )
        )
        
        self.netaloSDK = NetaloUISDK(config: config)
        self.netaloSDK.add(delegate: self)
        result(true)
    }
    
    private func setNetaloUser(call: FlutterMethodCall,result: @escaping FlutterResult) {
        
        do{
            guard let args = call.arguments else {
                return
            }
            
            let myArgs = args as! [String: Any]
            let  id = Int64(myArgs["id"] as! String) ?? 0
            
            self.userDemo = UserHolder(id: id,
                                     phoneNumber: formatPhone(phone: myArgs["phone"] as! String),
                                     email: "",
                                     fullName: myArgs["username"] as? String ?? "",
                                     avatarUrl: myArgs["avatar"] as? String ?? "",
                                     session: myArgs["token"] as? String ?? "")
            netaloSDK.set(user: self.userDemo!)
        } catch {
            print("error setNetaloUser: \(error)")
        }
        
        result(true)
    }
    
    private func registerRemoteToken() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            guard let deviceToken = UserDefaults.standard.data(forKey: "deviceToken") else { return }
            self.netaloSDK.application(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    func openChatWithUser(call: FlutterMethodCall,result: @escaping FlutterResult){
        guard let args = call.arguments else {
            return
        }
        
        let targetUserArgs = args as! [String: Any]
        
        let vc = ContainChatViewController.instantiate(sdk: self.netaloSDK)
        vc.data = targetUserArgs
        let nav = SwipeBackNavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(nav, animated: true, completion: nil)
        
        currentVC = nav
        result(true)
    }
    
    func formatPhone(phone:String) -> String{
        var result = phone
        if (phone.starts(with: "0")){
            result = phone.replacingCharacters(in: ...phone.startIndex, with: "+84")
        }
        return result
    }
    
    //  example check friend from flutter
    func checkIsFriend(netAloId: String = "0") {
        MethodChannel.instance.sendEventCheckIsFriend(targetNetAloId: netAloId, completion: {
            (isFriend:Bool)->() in
            XLog.print("checkFriend: \(isFriend)")
        })
    }
    
    func blockUser(call: FlutterMethodCall,result: @escaping FlutterResult) {
        guard let args = call.arguments else {
            return
        }
        
        let id = args as? Int ?? 0
        
        netaloSDK.block(useId: String(id)) { (success) in
            XLog.print("Block user \(success)")
            result(true)
        }
    }
    
    func unBlockUser(call: FlutterMethodCall,result: @escaping FlutterResult) {
        guard let args = call.arguments else {
            return
        }
        
        let id = args as? Int ?? 0
        
        netaloSDK.unBlock(useId: String(id)) { (success) in
            XLog.print("UnBlock user \(success)")
            result(true)
        }
    }
    
    func setImageDomain(call: FlutterMethodCall,result: @escaping FlutterResult) {
        guard let domain = call.arguments as? String else { return }
        // TODO: Need recheck, must set domain after init sdk
        self.netaloSDK.setUserProfileUrl(domain)
        XLog.print("Domain: \(self.netaloSDK.getUserProfileUrl())")
        
        result(true)
    }
    
    func openImagePicker(call: FlutterMethodCall,result: @escaping FlutterResult) {
        guard let args = call.arguments else {
            return
        }
        
        let myArgs = args as! [String: Any]
        let type = AssetMediaType(rawValue: myArgs["type"] as? Int ?? 0) ?? .all
        
        let vc = MultiImagePickerVC.instance(
            with: self,
            config: MultiImagePickerVC.Config(
                // Should return urls
                resultType: .url,
                // Should dismiss after press done
                autoDismiss: true,
                // Maximum number of media
                maxSelections: myArgs["maxImages"] as? Int ?? 1,
                // Should dismiss after reach max selections
                autoDismissOnMaxSelections: myArgs["autoDismissOnMaxSelections"] as? Bool ?? false,
                
                showDoneButton: true,
                assetMediaType: type
            )
        )
        self.topMostViewController()?.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Application Delegates
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        netaloSDK.applicationDidBecomeActive(application)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        netaloSDK.applicationWillTerminate(application)
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        netaloSDK.applicationWillResignActive(application)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        netaloSDK.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        UserDefaults.standard.setValue(deviceToken, forKey: "deviceToken")
        //Messaging.messaging().apnsToken = deviceToken
        //super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return netaloSDK.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    override func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        XLog.print("urlDeepLink: \(url.absoluteString)")
        MethodChannel.instance.sendEventDeepLink(url:url.absoluteString)
        return true
    }
    // Report Push Notification attribution data for re-engagements
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        XLog.print("urlDeepLink: \(url.absoluteString)")
        MethodChannel.instance.sendEventDeepLink(url:url.absoluteString)
        return true
    }
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
}


extension AppDelegate {
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
        
        self.netaloSDK.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
    
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        
        self.netaloSDK.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
}

//MARK: -NetaloUIDelegate
extension AppDelegate: NetaloUIDelegate {
    func pop(to viewController: UIViewController) {
        
    }
    
    func getConversationViewController() -> UIViewController? {
        return nil
    }
    
    func sessionExpired() {
        MethodChannel.instance.sendEventNetAloSessionExpire()
    }
    
    func userDidLogout() {}
    
    func present(viewController: UIViewController) {
        self.topMostViewController()?.present(viewController, animated: false, completion: nil)
    }
    
    func push(viewController: UIViewController) {
        self.topMostViewController()?.present(viewController, animated: false, completion: nil)
    }
    
    func openContact() {}
    
    func switchToMainScreen() {
        openChatConversation(result: nil)
    }
    
    func topMostViewController() -> UIViewController? {
        if let topController = UIApplication.topViewController() {
            print("TOPVC - \(topController)")
            return topController
        }
        return nil
    }
    
    func getContactViewController() -> UIViewController? {
        return nil
    }
    
    func updateStatusBar(style: UIStatusBarStyle) {}
    
    func updateThemeColor(_ themeColor: Int) {}
    
    func checkChatFunctions(with userId: String) {
        MethodChannel.instance.sendEventCheckIsFriend(targetNetAloId: userId, completion: {
            (isFriend:Bool)->() in
            XLog.print("checkFriend: \(isFriend)")
            self.netaloSDK.setFunctionInChat(
                with: userId,
                config: FeatureConfig.ChatConfig(
                    isVideoCallEnable: isFriend,
                    isVoiceCallEnable: isFriend)) { (success) in
                XLog.print(success)
            }
        })
    }
    
    func didPressed(url: String) {
        print(#line, url)
        MethodChannel.instance.sendEventHandleLinkFromNetAlo(url: url)
    }
    
    func closeSDK(completion: (()->())? = nil) {
        self.netaloSDK.exit()
        self.currentVC?.dismiss(animated: true) { [weak self] in
            completion?()
            self?.currentVC = nil
        }
    }
    
    func didClose() {
        MethodChannel.instance.sendEventNetAloExit()
    }
}


//MARK: -UIApplication
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


extension AppDelegate: MultiImagePickerDelegate {
    func didTapCloseButton() {
        XLog.print("Close")
    }
    
    func multiImagePickerVC(_ viewController: MultiImagePickerVC, didSelect images: [URL], videos: [URL]) {
        XLog.print(images)
        XLog.print(videos)
    }
}

