//
//  Announceable.swift
//  
//
//  Created by Pavel Skaldin on 4/8/21.
//

import Foundation

/**
 I define how to be Announceable.
 
 Announceables can be used for notifying observers of an `Announcer`.
 */
public protocol Announceable {
    /// Optional logic to perform immediately before delivering an announcement
    func prepareForAnnouncement()
    /// Answers whether an announcement of this type should be handled
    static func handles<T:Announceable>(_ anAnnouncement: T) -> Bool
}

extension Announceable {
    public func prepareForAnnouncement() {
        // nothing to do
    }
    
    public static func handles<T:Announceable>(_ anAnnouncement: T) -> Bool {
        guard let _ = anAnnouncement as? Self else { return false }
        return true
    }
}
