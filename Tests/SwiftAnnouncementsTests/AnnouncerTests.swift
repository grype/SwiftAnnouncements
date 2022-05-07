//
//  File.swift
//  
//
//  Created by Pavel Skaldin on 4/10/21.
//

import XCTest
import Nimble
@testable import SwiftAnnouncements

extension String : Announceable {}

class TestAnnouncement : Announceable {}
class TestAnnouncementSubclass : TestAnnouncement {}

fileprivate class Base: Announceable {}
fileprivate class SubBase: Base {}

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
    
    func testAnnouncingSubclass() {
        var result: TestAnnouncement?
        announcer.when(TestAnnouncement.self) { (anAnnouncement, _) in
            result = anAnnouncement
        }
        announcer.announce(TestAnnouncementSubclass())
        expect(result).to(beAKindOf(TestAnnouncementSubclass.self))
    }
    
    func testAnnouncingSuperclass() {
        var result: TestAnnouncement?
        announcer.when(TestAnnouncementSubclass.self) { (anAnnouncement, _) in
            result = anAnnouncement
        }
        announcer.announce(TestAnnouncement())
        expect(result).to(beNil())
    }
    
    func testAnnouncingSubclassWhileObservingHierarchy() {
        var results = [String]()
        announcer.when(TestAnnouncement.self) { (aFoo, _) in
            results.append("Foo")
        }
        announcer.when(TestAnnouncementSubclass.self) { (aBar, _) in
            results.append("Bar")
        }
        announcer.announce(TestAnnouncementSubclass())
        expect(results.count) == 2
        expect(results).to(contain("Foo"))
        expect(results).to(contain("Bar"))
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
    
    func testWeakSubscriber() {
        class Foo {}
        var foo: Foo? = Foo()
        announcer.when(String.self, subscriber: foo) { (_, _) in
            // nothing to do
        }
        foo = nil
        expect(self.announcer.registry.subscriptions.first!.subscriber).to(beNil())
        let subscription = self.announcer.registry.subscriptions.first?.base as! Subscription<String>
        expect(subscription.subscriber).to(beNil())
    }
    
    func testUnsubscribesReleasedSubscriber() {
        class Foo {
            var announcer: Announcer
            deinit {
                announcer.unsubscribe(self)
            }
            init(_ anAnnouncer: Announcer) {
                announcer = anAnnouncer
            }
        }
        
        var foo: Foo? = Foo(self.announcer)
        foo!.announcer.when(String.self, subscriber: foo!) { (_, _) in
            // nothing to do
        }
        expect(self.announcer.registry.subscriptions.count) == 1
        foo = nil
        expect(self.announcer.registry.subscriptions.isEmpty).to(beTrue())
    }
    
    func testOnceIsInvokedOnce() {
        var count = 0
        announcer.once(TestAnnouncement.self) { _, _ in
            count = count + 1
            return true
        }
        announcer.announce(TestAnnouncement())
        announcer.announce(TestAnnouncement())
        expect(count) == 1
        expect(self.announcer.registry.subscriptions.isEmpty).to(beTrue())
    }
    
    func testOnceThatNeverSucceeds() {
        var count = 0
        announcer.once(TestAnnouncement.self) { _, _ in
            count = count + 1
            return false
        }
        announcer.announce(TestAnnouncement())
        announcer.announce(TestAnnouncement())
        expect(count) == 2
        expect(self.announcer.registry.subscriptions.isEmpty).to(beFalse())
    }
    
    func testIdentificationOfAnnounceableSubclass() {
        var count: Int = 0
        announcer.when(SubBase.self) { _, _ in
            count += 1
        }
        announcer.announce(SubBase())
        expect(count) == 1
        announcer.announce(Base())
        expect(count) == 1
    }
    
    func testSubclassDifferentiation() {
        var baseCount: Int = 0
        var subBaseCount: Int = 0
        announcer.when(Base.self) { _, _ in
            baseCount += 1
        }
        announcer.when(SubBase.self) { _, _ in
            subBaseCount += 1
        }
        announcer.announce(Base())
        expect(baseCount) == 1
        expect(subBaseCount) == 0
        announcer.announce(SubBase())
        expect(baseCount) == 2
        expect(subBaseCount) == 1
    }
    
    func testAnnouncerPerformance() {
        let announcer = Announcer()
        announcer.when(String.self) { (_, _) in
        }
        measure {
            for _ in 1..<10000 {
                announcer.announce("")
            }
        }
    }
    
    func testNotificationCenterPerfomance() {
        let center = NotificationCenter.default
        center.addObserver(forName: NSNotification.Name(rawValue: "test"), object: nil, queue: nil) { (aNotification) in
        }
        measure {
            for _ in 1..<10000 {
                center.post(name: NSNotification.Name(rawValue: "test"), object: nil, userInfo: nil)
            }
        }
    }
}
