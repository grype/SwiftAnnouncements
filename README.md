# Announcements

Announcements is an alternative implementation of the Observer pattern, similar to `NSNotificationCenter` but with a few key differences: 

- Subscription is block based
- Thread-safe and thread-agnostic - notificatoins are delivered in the same thread they are posted
- Notifications are delivered to all subscribers, without additional rules such as binding to a specific object
- Handling of notifications does not require a run loop

### Example:

```swift
extension String : Announcement { }

let announcer = Announcer()
let subscription = announcer.when(String.self) { (aString, anAnnouncer) in
    print("Received announcement: \(aString)")
}
announcer.announce("Drink Water!")
announcer.remove(subscription: subscription)
```

Observers subscribe to announcements using `when()` method. Announcements are made by calling `announce()` method, passing in the announcement object. Any class/struct/enum can be made announceable by simply extending it to conform to `Announcement` protocol. No additional setup is required.

Removing observation is a matter of removing the subscription object, which is returned by `when()` method.

Alternativaly, subscribers can be captured and removed w/o the need to store subscriptions:

```swift
announcer.when(String.self, subscriber:self) { (aString, anAnnouncer) in
    // do something useful
}
announcer.ubsubscribe(self)
```

### Threading

Behind the scenes the `Announcer` keeps a `Registry` of all `Subscription`s. Access to that registry is governed by a Read-Write lock, making operations thread-safe such that no changes to the registry will take place until all announcements have been processed, and no announcements will be processed until registry contents are modified. Handling of announcements can happen concurrently. See Tests for details...
