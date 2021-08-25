//
//  RMNewContact.swift
//  Netalo
//
//  Created by Van Tien Tu on 6/5/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import RealmSwift

internal class RMContact: Object {
    var id = RealmOptional<Int64>()
    @objc dynamic var fullName: String? = nil
    @objc dynamic var email: String? = nil
    @objc dynamic var phone: String? = nil
    @objc dynamic var isFriend: Bool = true
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var displayName: String? = nil
    @objc dynamic var localContact: RMLocalContact?
    @objc dynamic var profileUrl: String? = nil
    @objc dynamic var userStatus: RMUserStatus?
    @objc dynamic var lastSeenAt: Double = 0
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

extension RMContact {
    
    enum Filter {
        case phone(condition: FilterConditions)
        case isFriend(Bool)
        case id(condition: FilterByIDConditions)
        case displayName(condition: FilterConditions)
        case isDeleted(Bool)
        
        var key: String {
            switch self {
            case .phone:
                return "\(#keyPath(RMContact.phone))"
            case .isFriend:
                return "\(#keyPath(RMContact.isFriend))"
            case .id:
                return "id"
            case .displayName:
                return "\(#keyPath(RMContact.displayName))"
            case .isDeleted:
                return "\(#keyPath(RMContact.isDeleted))"
            }
        }
    }
    
    enum FilterConditions {
        case equal(String?)
        case notEqual(String?)
        case contains(String?)
        case like(String?)
        case beginsWith(String?)
        
        func predicate(key: String) -> NSPredicate {
            switch self {
            case .equal(let data):
                return NSPredicate(format: "\(key) == %@", (data ?? "nil"))
            case .notEqual(let data):
                return NSPredicate(format: "\(key) != %@", data ?? "nil")
            case .contains(let data):
                return NSPredicate(format: "\(key) CONTAINS[cd] %@", (data ?? ""))
            case .like(let data):
                return NSPredicate(format: "\(key) LIKE '*\(data ?? "")*'")
            case .beginsWith(let data):
                return NSPredicate(format: "\(key) BEGINSWITH %@", (data ?? ""))
            }
        }
    }
    
    enum FilterByIDConditions {
        case idIn(data: [Int64])
        case idNotIn(data: [Int64])
        case id(Int64?)
        
        func predicate(key: String) -> NSPredicate {
            switch self {
            case .idIn(let data):
                return NSPredicate(format: "(\(key) IN %@)", data)
            case .idNotIn(let data):
                return NSPredicate(format: "NOT (\(key) IN %@)", data)
            case .id(let data):
                return NSPredicate(format: "\(key) == \(data ?? 0)")
            }
        }
    }
    
    static func filter(by filter: Filter) -> NSPredicate {
        let key = filter.key
        switch filter {
        case .phone(let condition):
            return condition.predicate(key: key)
        case .isFriend(let data):
            return NSPredicate(format: "\(key) == \(data)")
        case .id(let condition):
            return condition.predicate(key: key)
        case .displayName(let condition):
            return condition.predicate(key: key)
        case .isDeleted(let data):
            return NSPredicate(format: "\(key) == \(data)")
        }
    }
}
