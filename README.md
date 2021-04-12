# Announcements

Announcements is an alternative implementation of the Observer pattern, similar to `NSNotificationCenter` but with a few key differences: 

- Subscription is block based
- Any type of object can be announced
- Thread-safe and thread-agnostic - announcements are delivered in the same thread they are announced
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

Behind the scenes an `Announcer` keeps a `Registry` of all `Subscription`s. Access to that registry is governed by a Read-Write lock, making operations thread-safe such that no changes to the registry will take place until all announcements have been processed, and no announcements will be processed until registry contents are modified. Handling of announcements can happen concurrently. See Tests for details...
