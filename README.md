# Announcements

[![CI](https://github.com/grype/SwiftAnnouncements/actions/workflows/main.yml/badge.svg)](https://github.com/grype/SwiftAnnouncements/actions/workflows/main.yml)

An event dispatch mechanism for broadcasting of information to registered observers. 
It is similar to `NSNotificationCenter`, but with a few notable differences: 

- Any type of value can be announced
- Subscription is block-based
- Delivery is thread-agnostic - announcements are delivered in the same thread they are made
- Processing announcements does not require a run loop

### Example:

```swift
// Any type can be made Announceable
extension String : Announceable { }

let announcer = Announcer()

// Subscribe to observe values of an Announceable type
let subscription = announcer.when(String.self) { (aString, anAnnouncer) in
    print("World says: \(aString)")
}

// Notify observers by announcing an Announceable value
announcer.announce("Drink Water!")

// Stop observing by removing the subscription object
announcer.remove(subscription: subscription)

// Alternatively, use an arbitrary object for managing subscriptions:
announcer.when(String.self, subscriber:self) { (aString, anAnnouncer) in
    print("Received announcement: \(aString)")
}

// Unsubscribe when no longer interested
announcer.ubsubscribe(self)
```

### Threading

Behind the scenes an `Announcer` keeps a `Registry` of all `Subscription`s. Access to that registry is governed by a Read-Write lock, making operations thread-safe such that no changes to the registry will take place until all announcements have been processed, and no announcements will be processed while registry contents are being modified. Handling of announcements can happen concurrently. See Tests for details...
