# Announcements

[![CI](https://github.com/grype/SwiftAnnouncements/actions/workflows/main.yml/badge.svg)](https://github.com/grype/SwiftAnnouncements/actions/workflows/main.yml)

An event dispatch mechanism that allows broadcast of information to registered observers. 
It is similar to `NSNotificationCenter`, but with a few notable differences: 

- Any type of object can be announced
- Subscription is block based 
- Thread-agnostic - announcements are delivered in the same thread they are announced
- Handling of announcements does not require a run loop

### Example:

```swift
// Any type can be made Announceable
extension String : Announceable { }

let announcer = Announcer()

// Observers subscribe to announcements by type
let subscription = announcer.when(String.self) { (aString, anAnnouncer) in
    print("World says: \(aString)")
}

// Notify observers by making an announcement
announcer.announce("Drink Water!")

// Stop observing by removing the subscription object
announcer.remove(subscription: subscription)

// Alternatively, use an arbitrary subscriber object for managing subscriptions:
announcer.when(String.self, subscriber:self) { (aString, anAnnouncer) in
    print("Received announcement: \(aString)")
}
announcer.ubsubscribe(self)
```

### Threading

Behind the scenes an `Announcer` keeps a `Registry` of all `Subscription`s. Access to that registry is governed by a Read-Write lock, making operations thread-safe such that no changes to the registry will take place until all announcements have been processed, and no announcements will be processed while registry contents are being modified. Handling of announcements can happen concurrently. See Tests for details...
