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
}
