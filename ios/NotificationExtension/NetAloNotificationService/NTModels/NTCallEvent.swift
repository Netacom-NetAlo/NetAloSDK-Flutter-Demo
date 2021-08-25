//
//  IMCallEvent.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/2/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public enum NTCallEvent: Encodable {
    case startCall(NTCall)
    case createCall(NTCall)
    case answerCall(NTAnswerCall)
    case stopCall(NTStopCall)
    case iceSdp(NTIceSdp)
    case iceCandidate(NTIceCandidate)
    case customEvent(NTEvent)
    case sendEventCall(NTStartCall)
    
    enum Key: String, CodingKey {
        case startCall = "start_call"
        case createCall = "create_call"
        case answerCall = "answer_call"
        case stopCall = "stop_call"
        case iceSdp = "ice_sdp"
        case iceCandindate = "ice_candidate"
        case customEvent = "event"
        case sendEventCall = "call_event"
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        
        switch self {
        case .startCall(let data):
            try container.encode(data, forKey: .startCall)
        case .createCall(let data):
            try container.encode(data, forKey: .createCall)
        case .answerCall(let data):
            try container.encode(data, forKey: .answerCall)
        case .stopCall(let data):
            try container.encode(data, forKey: .stopCall)
        case .iceSdp(let data):
            try container.encode(data, forKey: .iceSdp)
        case .iceCandidate(let data):
            try container.encode(data, forKey: .iceCandindate)
        case .customEvent(let data):
            try container.encode(data, forKey: .customEvent)
        case .sendEventCall(let data):
            try container.encode(data, forKey: .sendEventCall)
//        default:
//            break
        }
    }
    
    func type() -> String {
        switch self {
        case .startCall:
            return "start_call"
        case .createCall:
            return "create_call"
        case .answerCall:
            return "answer_call"
        case .stopCall:
            return "stop_call"
        case .iceSdp:
            return "ice_sdp"
        case .iceCandidate:
            return "ice_candidate"
        case .customEvent:
            return "event"
        case .sendEventCall:
            return "call_event"
        }
    }
    
    public func toDictionary() -> [String: Any] {
        
        guard
            let data = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                
                return [:]
        }
        
        return (dictionary[type()] as? [String: Any]) ?? [:]
    }
}
