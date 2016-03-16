//
//  LRUCache.swift
//  LRUCache
//
//  Created by Doug Whitmore on 3/4/16.
//  Copyright © 2016 Good Doug. All rights reserved.
//

import Foundation

internal class ListItem <Key: Hashable, Value> {
    let key: Key
    let value: Value
    var next: ListItem<Key, Value>? = nil
    var prev: ListItem<Key, Value>? = nil
    init(withKey key: Key, value: Value) {
        self.value = value
        self.key = key
    }
}

extension ListItem: CustomStringConvertible {
    var description: String {
        get {
            return "\(String(key)): \(String(value))"
        }
    }
}

/**
 Simple implementation of a basic Least Recently Used (LRU) cache
 - init with a maxSize > 0 (default = 32)
*/
public class LRUCache<Key: Hashable, Value> {
    var hashtable: [Key: ListItem<Key, Value>] = [:]
    var head: ListItem<Key, Value>? = nil
    var tail: ListItem<Key, Value>? = nil
    let maxSize: UInt
    
    let lock = NSLock()
    
    /// for testing, don't rely on this
    var size: UInt {
        get {
            var acc: UInt = 0
            apply({ item in
                acc = acc + self.sizeOfItem(item.value)
            })
            return acc
        }
    }
    
    /**
     function for determining the size of a value inserted into the cache
     by default, it uses a simpe count. This could be used for size in bytes,
     length of strings, or any other integer measurement
     */
    var sizeOfItem: (Value)-> UInt = { item in
        return 1
    }
    
    /**
     precondition: maxSize > 0 or it will crash
    */
    init(maxSize: UInt = 32) {
        precondition(maxSize > 0, "Can't have a cache smaller than one item")
        self.maxSize = maxSize
    }
    
    /**
     Returns the value for a given key if it is in the cache. Also sets it to be last item
     to be kicked from the cache in the event of overflow. If the item is not in the cache,
     returns None
    */
    public func itemForKey(key: Key) -> Value? {
        lock.lock()
        defer {
            lock.unlock()
        }
        guard let item = hashtable[key] else { return nil }
        bubbleUp(item)
        return item.value
    }
    
    /**
     Sets the value for a particular key in the cache. Can either add a new value or will update
     the value for that key in the cache. Also sets that item to be last to get kicked from the
     cache in the event of overflow
    */
    public func setItem(val: Value, forKey key:Key) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if let oldValue = hashtable[key] {
            self.removeItemFromList(oldValue)
        }
        let item = ListItem(withKey: key, value: val)
        bubbleUp(item)
        hashtable[key] = item
        // cleanup
        while size > maxSize {
            guard !(tail === head) else { return } // if only one item in list, don't remove it, no matter the size
            if let tail = self.tail {
                hashtable.removeValueForKey(tail.key)
                removeItemFromList(tail)
            }
        }
    }
    
    func bubbleUp(item: ListItem<Key, Value>) {
        guard !(item === head) else { return }
        removeItemFromList(item)
        if let oldHead = head {
            item.next = oldHead
            oldHead.prev = item
        } else {
            // list empty, item is also the tail
            tail = item
        }
        item.prev = nil
        head = item
    }
    
    func removeItemFromList(item: ListItem<Key, Value>) {
        if let prev = item.prev {
            prev.next = item.next
        }
        if let next = item.next {
            next.prev = item.prev
        }
        if item === tail {
            tail = item.prev
        }
    }
}

extension LRUCache {
    func apply(f: (ListItem<Key, Value>)->()) {
        var val = head
        while val != nil {
            f(val!)
            val = val!.next
        }
    }
}

extension LRUCache {
    public var descriptionString: String {
        get {
            var acc: [String] = []
            apply {
                acc.append(String($0))
            }
            acc.append("•")
            return acc.joinWithSeparator("\n")
        }
    }
}
