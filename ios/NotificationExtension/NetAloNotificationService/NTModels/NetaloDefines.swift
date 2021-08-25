//
//  Defines.swift
//  NetaloSDK
//
//  Created by Nguyên Duy on 5/15/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

public struct NTDefines {
    public enum OnlineStatus: Int {
        case unknown            = 0
        case online             = 1
        case offline            = 2
        case idle               = 3
        case invisible          = 4
        case away               = 5
        case busy               = 6
    }

    public enum GroupType: Int {
        case unknown            = 0
        case privateGroup       = 1
        case group              = 2
        case publicGroup        = 3
    }

    public enum Answer: Int {
        case unknown            = 0
        case yes                = 1
        case no                 = 2
        case failed             = 3
        case unrecognized       = -1
    }

    public enum IgnoreType: Int {
        case unknown            = 0
        case ignore             = 1
        case unignore           = 2
        case get                = 3
        case unrecognized       = -1
    }

    public enum MessageStatus: Int {
        case unknown            = 0
        case sent               = 1
        case received           = 2
        case seen               = 3
        case deleted            = 4
        case unrecognized       = -1
    }
    
    public enum TokenType: Int {
        case unknown            = 0
        case fcm                = 1
        case apns               = 2
        case pushkit            = 4
    }
    
    public enum GroupSortType: Int {
        case random             = 0
        case byLastMessage      = 1
        case byCreatedAt        = 2
    }
}
