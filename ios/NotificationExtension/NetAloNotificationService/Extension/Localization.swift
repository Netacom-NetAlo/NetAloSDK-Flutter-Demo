//
//  Localization.swift
//  Netalo
//
//  Created by Nhu Nguyet on 12/22/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import Foundation
import Localize_Swift

final class BundleToken {}

extension String {
    var localized: String {
        return localized(in: Bundle(for: BundleToken.self))
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
    
    func localizedPlural(_ argument: CVarArg) -> String {
        if Localize.currentLanguage() == "en" {
            let format = NSLocalizedString(self, comment: "")
            return String.localizedStringWithFormat(format, argument)
        } else {
            return localizedFormat(argument)
        }
    }
}
