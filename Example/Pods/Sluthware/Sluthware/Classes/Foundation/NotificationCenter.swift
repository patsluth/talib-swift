//
//  NotificationCenter.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-12.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public extension NotificationCenter
{
    @objc func postMain(_ notification: Notification)
    {
        self.performSelector(onMainThread: #selector(self.post(_:)), with: notification, waitUntilDone: true)
    }
    
    @objc func postMain(name aName: NSNotification.Name, object anObject: Any?)
    {
        let notification = Notification.init(name: aName, object: anObject)
        self.postMain(notification)
    }
    
    @objc func postMain(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable: Any]? = nil)
    {
        let notification = Notification.init(name: aName, object: anObject, userInfo: aUserInfo)
        self.postMain(notification)
    }
}




