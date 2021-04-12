//
//  Registry.swift
//  
//
//  Created by Pavel Skaldin on 4/8/21.
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
        subscriptions.removeAll { (each) -> Bool in
            return each.subscriber === subscriber
        }
    }
    
    public func removeAllSubscriptions() {
        subscriptions.removeAll()
    }
    
    // MARK:- Announcing
    
    func deliver<T: Announceable>(_ anAnnouncement: T) {
        subscriptions.forEach { (aSubscription) in
            guard let aSubscription = aSubscription.base as? Subscription<T> else { return }
            aSubscription.action(anAnnouncement, aSubscription.announcer)
        }
    }
    
}

/**
 I am a type-erased announcement subscription.
 
 I am used by the `Registry` to store its subscriptions.
 */
public struct AnySubscription {
    
    public var base: Any
    public var subscriber: AnyObject?
    
    public init<H,S:Announceable>(_ aBase: H) where H : Subscription<S> {
        base = aBase
        subscriber = aBase.subscriber
    }
}
