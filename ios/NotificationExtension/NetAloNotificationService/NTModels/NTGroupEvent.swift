//
//  IMGroupEvent.swift
//  NetaloSDK
//
//  Created by Tran Phong on 6/12/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTGroupEvent: Encodable {
    public let groupID: String
    public let kind: NTGroupEventKind
    
    enum Key: String, CodingKey {
        case groupID
        case kind
    }
    
    public init(groupID: String, kind: NTGroupEventKind) {
        self.groupID = groupID
        self.kind = kind
    }
}

public enum NTGroupEventKind: Encodable {
    case startTyping
    case stopTyping
    case updateMessage(NTMessage)
    case deleteMessage(NTMessage)

    enum Key: String, CodingKey {
        case startTyping = "start_typing"
        case stopTyping = "stop_typing"
        case updateMessage = "update_message"
        case deleteMessage = "delete_message"
        case type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(type(), forKey: .type)
    }
    
    func type() -> Int {
        switch self {
        case .startTyping:
            return NTEvent.EVENT_TYPE_MESSAGING_START_TYPING
        case .stopTyping:
            return NTEvent.EVENT_TYPE_MESSAGING_STOP_TYPING
        default:
            return NTEvent.EVENT_TYPE_UNKNOWN
        }
    }
}
