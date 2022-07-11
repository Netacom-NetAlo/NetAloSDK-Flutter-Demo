//
//  MethodChannel.swift
//  Runner
//
//  Created by Meo Luoi on 18/11/2020.
//

import Foundation

class MethodChannel{
    static let instance = MethodChannel()
    private var sendChannel:FlutterMethodChannel?
    private let sendChannelName = "callbacks"
    public var receiveChannel:FlutterMethodChannel?
    private let receiveChannelName = "com.netacom.flutter_sdk/flutter_channel"
    
    init(){}
    
    func initChannel(messenger:FlutterBinaryMessenger){
        sendChannel = FlutterMethodChannel(name: sendChannelName,
                                           binaryMessenger: messenger)
        
        receiveChannel = FlutterMethodChannel(name: receiveChannelName,
                                              binaryMessenger:messenger)
    }
    
    func sendResult(){
        self.sendChannel?.invokeMethod("callListener", arguments: ["name":"hehe","age":1])
    }
    
    func sendEventNetAloSessionExpire(){
        self.sendChannel?.invokeMethod("netAloSessionExpire", arguments: [])
    }
    
    func sendEventNetAloExit() {
        self.sendChannel?.invokeMethod("netAloExit", arguments: [])
    }
    
    func sendEventShowToast(message:String){
        self.sendChannel?.invokeMethod("showToast", arguments: message)
    }
    
    func sendEventDeepLink(url:String?){
        self.sendChannel?.invokeMethod("sendEventDeepLink", arguments: url)
    }
    
    func sendEventHandleLinkFromNetAlo(url:String?){
        self.sendChannel?.invokeMethod("sendEventHandleLinkFromNetAlo", arguments: url)
    }
    
    func sendEventCheckIsFriend(targetNetAloId: String = "0", completion: @escaping (Bool) -> ()){
        self.sendChannel?.invokeMethod("checkIsFriend", arguments: targetNetAloId, result: {(r:Any?) -> () in
            completion(r as? Bool ?? false)
        })
    }
}
