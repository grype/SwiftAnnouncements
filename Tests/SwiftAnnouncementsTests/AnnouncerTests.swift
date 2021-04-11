//
//  File.swift
//  
//
//  Created by Pavel Skaldin on 4/10/21.
//

import XCTest
import Nimble
@testable import SwiftAnnouncements

extension String : Announcement {}

class AnnouncerTest: XCTestCase {
    
    private var announcer: Announcer!
    
    private var announcement = "Drink Water!"
    
    override func setUp() {
        super.setUp()
        announcer = Announcer()
    }
    
    override func tearDown() {
        super.tearDown()
        announcer.removeAllSubscriptions()
    }
    
    // MARK:- Subscribing
    
    func testSubscribing() {
        announcer.when(String.self) { (_, _) in
            // nothind to do
        }
        expect(self.announcer.registry.subscriptions.count) == 1
    }
    
    func testSubscribingMultipleTimes() {
        announcer.when(String.self) { (_, _) in
            // nothind to do
        }
        announcer.when(String.self) { (_, _) in
            // nothind to do
        }
        expect(self.announcer.registry.subscriptions.count) == 2
    }
    
    // MARK:- Announcing
    
    func testAnnouncing() {
        var result = ""
        announcer.when(String.self) { (aString, _) in
            result = aString
        }
        announcer.announce(announcement)
        expect(result) == announcement
    }
    
    func testAnnouncingMultipleTimes() {
        var result = [String]()
        announcer.when(String.self) { (aString, _) in
            result.append(aString)
        }
        announcer.announce("One")
        announcer.announce("Two")
        expect(result) == ["One", "Two"]
    }
    
    func testAnnouncementDispatch() {
        var result: Thread? = nil
        announcer.when(String.self) { (_, _) in
            result = Thread.current
        }
        waitUntil { (done) in
            DispatchQueue.global().async {
                self.announcer.announce(self.announcement)
                expect(result) === Thread.current
                done()
            }
        }
    }
    
    func testAsyncSerialAnnouncing() {
        var result = [String]()
        announcer.when(String.self) { (aString, _) in
            result.append(aString)
        }
        
        let queue = DispatchQueue(label: "AnnouncerTestQueue")
        
        waitUntil { (done) in
            queue.async {
                self.announcer.announce("One")
            }
            queue.async {
                self.announcer.announce("Two")
            }
            queue.async {
                expect(result) == ["One", "Two"]
                done()
            }
        }
    }
    
    func testAnnouncingAfterUnsubscribing() {
        var result = [String]()
        announcer.when(String.self, subscriber: self) { (aString, _) in
            result.append(aString)
        }
        announcer.unsubscribe(self)
        announcer.announce(announcement)
        expect(result.isEmpty) == true
    }
    
    // MARK:- Unsubscribing
    
    func testRemovingSubscription() {
        let subscription = announcer.when(String.self) { (_, _) in
            // nothind to do
        }
        announcer.remove(subscription: subscription)
        expect(self.announcer.registry.subscriptions.count) == 0
    }
    
    func testRemovingSubscriber() {
        announcer.when(String.self, subscriber: self) { (_, _) in
            // nothind to do
        }
        announcer.unsubscribe(self)
        expect(self.announcer.registry.subscriptions.count) == 0
    }
    
    func testRemovingSubscriberFromMany() {
        announcer.when(String.self, subscriber: self) { (_, _) in
            // nothind to do
        }
        announcer.when(String.self, subscriber: self) { (_, _) in
            // nothind to do
        }
        let subscription = announcer.when(String.self) { (_, _) in
            // nothind to do
        }
        announcer.unsubscribe(self)
        expect(self.announcer.registry.subscriptions.count) == 1
        let remainingSubscription = self.announcer.registry.subscriptions.first!.base as! Subscription<String>
        expect(remainingSubscription) === subscription
    }
    
}
