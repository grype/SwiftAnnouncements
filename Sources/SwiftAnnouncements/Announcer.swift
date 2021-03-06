//
//  Announcer.swift
//  
//
//  Created by Pavel Skaldin on 4/8/21.
//  Copyright © 2021 Pavel Skaldin. All rights reserved.
//

import Foundation


/**
 I provide a thread-safe mechanism for notifying subscribers of arbitrary announcements.
 
 ### Subscribing
 
 Observers subscribe to announcements using `when(_:subscriber:do:)`. For example:
 
 ```
 extension String : Announceable {}
 let announcer = Announcer()
 
 let subscription = announcer.when(String.self) { (aString, anAnnouncer) in
    print(aString)
 }
 
 // or passing in an arbitrary subscriber object
 announcer.when(String.self, subscriber: self) { (aString, anAnnouncer) in
    print(aString)
 }
 
 ```
 
 The subscriber is optional and `when()` returns a `Subscription` object. Either object is required for unsubscribing (see below).
 
 ### Announcing
 
 Making an announcement would evaluate blocks of code with which observers had previously subscribed, provided they match the type (or the type inherits from the type used in subscription):
 
 ```
 announcer.when(String.self) { (aString, _) in
    print(aString)
 }
 announcer.announce("Drink Water!") // will result in above print statement
 
 class Foo : Announceable {}
 class Bar : Foo {}
 announcer.when(Foo.self) { (aFoo, _) in
    print("Foo")
 }
 announcer.when(Bar.self) { (aBar, _) in
    print("Bar")
 }
 announcer.announce(Foo()) // will print "Foo"
 announcer.announce(Bar()) // will print "Foo" and "Bar"
 ```
 
 ### Unsubscribing
 
 When done observing, remove the subscription. This can be done in two ways:
 
 Using the subscriber object:
 
 ```
 announcer.when(String.self, subscriber: self) { ... }
 announcer.unsubscribe(self)
 ```
 
 By directly removing the `Subscription` object:
 
 ```
 let subscription = announcer.when(String.self) { ... }
 announcer.remove(subscription: subscription)
 ```
 
 ### Words of wisdom:
 
 - Be mindful about what you're capturing in your blocks when subscribing.
 - Blocks are evaluated in the same thread as the announcement.
 
 */
public class Announcer {
    
    private(set) var registry = Registry()
    
    // MARK:- Init
    
    public init() {}
    
    deinit {
        registry.removeAllSubscriptions()
    }
    
    // MARK:- Subscribing
    
    @discardableResult
    open func when<T: Announceable>(_ aType: T.Type, subscriber: AnyObject? = nil, do aBlock: @escaping (T, Announcer)->Void) -> Subscription<T> {
        let subscription = Subscription(action: aBlock, type: aType, announcer: self)
        subscription.subscriber = subscriber
        registry.add(subscription)
        return subscription
    }
    
    @discardableResult
    open func once<T: Announceable>(_ aType: T.Type, do aBlock: @escaping (T, Announcer)->Bool) -> Subscription<T> {
        let subscription = Subscription(action: { _,_ in }, type: aType, announcer: self)
        subscription.action = { announcement, announcer in
            guard aBlock(announcement, announcer) else { return }
            announcer.remove(subscription: subscription)
        }
        registry.add(subscription)
        return subscription
    }
    
    open func remove<T: Announceable>(subscription: Subscription<T>) {
        registry.remove(subscription)
    }
    
    open func removeAllSubscriptions() {
        registry.removeAllSubscriptions()
    }
    
    open func unsubscribe(_ anObject: AnyObject) {
        registry.remove(subscriber: anObject)
    }
    
    // MARK:- Announcing
    
    open func announce<T: Announceable>(_ announcement: T) {
        registry.deliver(announcement)
    }
    
    // MARK:- Accessing
    
    open var allSubscribers: [AnyObject] {
        return registry.subscriptions.compactMap { aSubscription in
            aSubscription.subscriber
        }
    }
    
}
