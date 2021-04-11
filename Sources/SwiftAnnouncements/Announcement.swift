//
//  Announcement.swift
//  
//
//  Created by Pavel Skaldin on 4/8/21.
//

import Foundation

/**
 I define an announcement.
 
 Announcements are used for notifying observers of an `Announcer`.
 */
public protocol Announcement {
    func prepareForAnnouncement()
    static func handles<T:Announcement>(_ anAnnouncement: T) -> Bool
}

extension Announcement {
    public func prepareForAnnouncement() {
        // nothing to do
    }
    
    public static func handles<T:Announcement>(_ anAnnouncement: T) -> Bool {
        return type(of: anAnnouncement) == self
    }
}
