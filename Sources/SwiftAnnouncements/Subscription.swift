//
//  Subscription.swift
//  
//
//  Created by Pavel Skaldin on 4/8/21.
//

import Foundation

/**
 I am an announcement subscription.
 
 I capture a type of announcement, an action block to perform in response to correlated announcement, and optionally a subscriber object. I am used by an `Announcer` to process announcements.
 */
public class Subscription<T: Announcement> {

    public typealias Action = (T, Announcer)->Void

    /// Action to perform when handling announcements
    public var action: Action
    
    /// Type of announcement for which associated action is handled
    public var announcementType: T.Type
    
    /// Captures the announcer that captures this subscription
    public var announcer: Announcer
    
    /// Optional subscriber object
    public var subscriber: AnyObject?

    init(action anAction: @escaping Action, type aType: T.Type, announcer anAnnouncer: Announcer) {
        action = anAction
        announcementType = aType
        announcer = anAnnouncer
    }

    public func deliver(_ anAnnouncement: T) {
        action(anAnnouncement, announcer)
    }
    
    public func handles<T:Announcement>(_ anAnnouncement: T) -> Bool {
        return type(of: anAnnouncement).handles(anAnnouncement)
    }

}
