//
//  RMLocalContact.swift
//  Netalo
//
//  Created by Van Tien Tu on 6/15/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import RealmSwift

internal class RMLocalContact: Object {
    @objc dynamic var phone: String = ""
    @objc dynamic var name: String = ""
    
    override public static func primaryKey() -> String? {
        return "phone"
    }
}

extension RMLocalContact {
    enum Filter {
        case phone(FilterConditions)
        
        var key: String {
            switch self {
            case .phone:
                return "\(#keyPath(RMLocalContact.phone))"
            }
        }
    }
    
    enum FilterConditions {
        case equal(String)
        case phoneNotIn(excludePhones: [String])
        
        func predicate(key: String) -> NSPredicate {
            switch self {
            case .equal(let data):
                return NSPredicate(format: "\(key) == %@", data)
            case .phoneNotIn(let excludePhones):
                return NSPredicate(format: "NOT (\(key) IN %@)", excludePhones)
            }
        }
    }
    
    static func filter(by filter: Filter) -> NSPredicate {
        let key = filter.key
        switch filter {
        case .phone(let condition):
            return condition.predicate(key: key)
        }
    }
}
