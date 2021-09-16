//
//  File.swift
//  
//
//  Created by Pavel Skaldin on 9/15/21.
//

import Foundation

/**
 I am a type-erased announcement subscription.
 
 I am used by the `Registry` to store its subscriptions.
 */
public struct AnySubscription {
    
    public var base: Any
    weak var subscriber: AnyObject?
    var subscriberAddress: Int?
    var handler: (Announceable) -> Void
    
    public init<H,S:Announceable>(_ aBase: H) where H : Subscription<S> {
        base = aBase
        subscriber = aBase.subscriber
        subscriberAddress = aBase.subscriberAddress
        handler = { (anAnnouncement) in
            guard let announcement = anAnnouncement as? S else { return }
            aBase.deliver(announcement)
        }
    }
}
