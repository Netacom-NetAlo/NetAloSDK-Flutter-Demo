//
//  String+Ext.swift
//  Netalo
//
//  Created by Van Tien Tu on 7/29/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation

extension String {
    var containsMentionText: Bool {
        return self.range(of: "@[1-9][0-9]{10,15}", options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension String {
    var escapedString: String {
        // \b = \u{8}
        // \f = \u{12}
        let escapedString = self
            .replacingOccurrences(of: "\"", with: "\\\"", options: .caseInsensitive)
            .replacingOccurrences(of: "/", with: "\\/", options: .caseInsensitive)
            .replacingOccurrences(of: "\\n", with: "\\\\\\n", options: .caseInsensitive)
            .replacingOccurrences(of: "\\u{8}", with: "\\\\\\b", options: .caseInsensitive)
            .replacingOccurrences(of: "\\u{12}", with: "\\\\\\f", options: .caseInsensitive)
            .replacingOccurrences(of: "\\r", with: "\\\\\\r", options: .caseInsensitive)
            .replacingOccurrences(of: "\\t", with: "\\\\\\t", options: .caseInsensitive)
        return escapedString
    }
    
    var unescapeString: String {
        let unescapedString = self
            .replacingOccurrences(of: "\\\"", with: "\"", options: .caseInsensitive)
            .replacingOccurrences(of: "\\/", with: "/", options: .caseInsensitive)
            .replacingOccurrences(of: "\\n", with: "\n", options: .caseInsensitive)
            .replacingOccurrences(of: "\\u{8}", with: "\u{8}", options: .caseInsensitive)
            .replacingOccurrences(of: "\\u{12}", with: "\u{12}", options: .caseInsensitive)
            .replacingOccurrences(of: "\\r", with: "\r", options: .caseInsensitive)
            .replacingOccurrences(of: "\\t", with: "\t", options: .caseInsensitive)
        return unescapedString
    }
    
    var replaceSpecialCharacters: String {
        let value = self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\t", with: "\\t")

        return value
    }
}
