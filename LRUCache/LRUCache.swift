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

public class LRUCache<Key: Hashable, Value> {
    var hashtable: [Key: ListItem<Key, Value>] = [:]
    var head: ListItem<Key, Value>? = nil
    var tail: ListItem<Key, Value>? = nil
    let maxSize: Int
    var count: Int = 0
    
    init(maxSize: Int = 32) {
        self.maxSize = maxSize
    }
    
    public func itemForKey(key: Key) -> Value? {
        guard let item = hashtable[key] else { return nil }
        bubbleUp(item)
        return item.value
    }
    
    public func setItem(val: Value, forKey key:Key) {
        if let oldValue = hashtable[key] {
            self.removeItemFromList(oldValue)
        }
        let item = ListItem(withKey: key, value: val)
        bubbleUp(item)
        hashtable[key] = item
        count = count + 1
        // cleanup
        while hashtable.count > maxSize {
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
        count = count - 1
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
