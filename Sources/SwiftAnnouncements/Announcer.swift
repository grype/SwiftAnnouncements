//
//  Announcer.swift
//  
//
//  Created by Pavel Skaldin on 4/8/21.
//

import Foundation


/**
 I provide a thread-safe mechanism for notifying subscribers using closures.
 
 I use an Observer pattern to notify observers of `Announcement`s.
 Observers subscribe using `when(_:subscriber:do:)`.
 Announcements are made by calling `announce(_:)`
 
 ### Subscribing
 
 Observers subscribe to announcements using `when(_:subscriber:do:)`. For example:
 
 ```
 extension String : Announcement {}
 let announcer = Announcer()
 
 announcer.when(String.self, subscriber: self) { (aString, anAnnouncer) in
    print(aString)
 }
 
 let subscription = announcer.when(String.self) { (aString, anAnnouncer) in
    print(aString)
 }
 ```
 
 The subscriber is optional and `when` method returns a `Subscription` object. Either object is required when unsubscribing (see below).
 
 ### Announcing
 
 Making an announcement would evaluate blocks of code with which observer had previously subscribed:
 
 ```
 announcer.announce("Drink Water!")
 ```
 
 ### Unsubscribing
 
 Of course, at some point the observers will need to unsubscribe. This can be done in two ways:
 
 Using the subscriber object:
 
 ```
 announcer.when(String.self, subscriber: self) { ... }
 announcer.unsubscribe(self)
 ```
 
 By removing the `Subscription` object:
 
 ```
 let subscription = announcer.when(String.self, subscriber: self) { ... }
 announcer.remove(subscription: subscription)
 ```
 
 ### Words of wisdom:
 
 - Be mindful about what you're capturing in your blocks when subscribing.
 - Blocks are evaluated in the same thread as the announcement.
 
 */
public class Announcer {
    
    private(set) var registry = Registry()
    
    deinit {
        registry.removeAllSubscriptions()
    }
    
    // MARK:- Subscribing
    
    @discardableResult
    open func when<T: Announcement>(_ aType: T.Type, subscriber: AnyObject? = nil, do aBlock: @escaping (T, Announcer)->Void) -> Subscription<T> {
        let subscription = Subscription(action: aBlock, type: aType, announcer: self)
        subscription.subscriber = subscriber
        registry.add(subscription)
        return subscription
    }
    
    open func remove<T: Announcement>(subscription: Subscription<T>) {
        registry.remove(subscription)
    }
    
    open func removeAllSubscriptions() {
        registry.removeAllSubscriptions()
    }
    
    open func unsubscribe(_ anObject: AnyObject) {
        registry.remove(subscriber: anObject)
    }
    
    // MARK:- Announcing
    
    open func announce<T: Announcement>(_ announcement: T) {
        registry.deliver(announcement)
    }
    
}
