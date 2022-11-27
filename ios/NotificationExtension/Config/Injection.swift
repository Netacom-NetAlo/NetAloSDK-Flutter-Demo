//
//  Injection.swift
//  NotificationExtension
//
//  Created by Hoang Do on 11/27/22.
//

import Resolver
import NotificationComponent

extension MyResolver: ResolverRegistering {
    public static func registerAllServices() {
        register { NotificationComponentImpl(enviroment: BuildConfig.enviroment, appGroupId: BuildConfig.appGroupId) as NotificationComponentImpl }
            .scope(.cached)
    }
}
