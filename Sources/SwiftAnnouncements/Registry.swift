//
//  Registry.swift
//  
//
//  Created by Pavel Skaldin on 4/8/21.
//  Copyright © 2021 Pavel Skaldin. All rights reserved.
//

import Foundation
import RWLock

/**
 I am a registry of announcement subscriptions.
 
 I am used by an `Announcer` to keep track of all subscriptions.
 I keep all subscriptions in a `ReadWriteLock`ed array. I am thread-safe.
 */
class Registry {
    
    // MARK:- Properties
    
    @RWLocked private(set) var subscriptions = [AnySubscription]()
    
    // MARK:- Adding/Removing
    
    public func add<T:Announceable>(_ aSubscription: Subscription<T>) {
        subscriptions.append(AnySubscription(aSubscription))
    }
    
    public func remove<T:Announceable>(_ aSubscription: Subscription<T>) {
        subscriptions.removeAll { (each) -> Bool in
            each.base as? Subscription<T> === aSubscription
        }
    }
    
    public func remove(subscriber: AnyObject) {
        subscriptions.removeAll { (aSubscription) -> Bool in
            return aSubscription.subscriberAddress == unsafeBitCast(subscriber, to: Int.self)
        }
    }
    
    public func removeAllSubscriptions() {
        subscriptions.removeAll()
    }
    
    // MARK:- Announcing
    
    func deliver<T: Announceable>(_ anAnnouncement: T) {
        subscriptions.forEach { (aSubscription) in
            aSubscription.handler(anAnnouncement)
        }
    }
    
}

/**
 I am a type-erased announcement subscription.
 
 I am used by the `Registry` to store its subscriptions.
 */
public struct AnySubscription {
    
    public var base: Any
    weak var subscriber: AnyObject?
    var subscriberAddress: Int?
    fileprivate var handler: (Announceable) -> Void
    
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
