//
//  LRUCache.swift
//  LRUCache
//
//  Created by Doug Whitmore on 3/4/16.
//  Copyright © 2016 Good Doug. All rights reserved.
//

import Foundation

class ListItem <Key: Hashable, Value> {
    let key: Key
    let value: Value
    var nextItem: ListItem<Key, Value>? = nil
    var prevItem: ListItem<Key, Value>? = nil
    init(withKey key: Key, value: Value) {
        self.value = value
        self.key = key
    }
}

extension ListItem: CustomStringConvertible {
    var description: String {
        get {
            return "\(String(describing: key)): \(String(describing: value))"
        }
    }
}

public struct ListItemGenerator <Key: Hashable, Value>: IteratorProtocol {
    public typealias Element = Value
    var currentItem: ListItem<Key, Value>?
    
    mutating public func next() -> Value? {
        guard let i = currentItem else { return nil }
        currentItem = i.nextItem
        return i.value
    }
}

/**
 Simple implementation of a basic Least Recently Used (LRU) cache
 - init with a maxSize > 0 (default = 32)
*/
open class LRUCache<Key: Hashable, Value> {
    fileprivate var hashtable: [Key: ListItem<Key, Value>] = [:]
    fileprivate var head: ListItem<Key, Value>? = nil
    fileprivate var tail: ListItem<Key, Value>? = nil
    let maxSize: Int
    
    fileprivate let lock = NSLock()
    
    var size: Int {
        get {
            let acc: Int = reduce(0) { curr, item in
                curr + self.sizeOfItem(item)
            }
            return acc
        }
    }
    
    /**
     function for determining the size of a value inserted into the cache
     by default, it uses a simple count. This could be used for size in bytes,
     length of strings, or any other integer measurement
     */
    var sizeOfItem: (Value)-> Int = { item in
        return 1
    }
    
    /**
     precondition: maxSize > 0 or it will crash
    */
    init(maxSize: Int = 32) {
        precondition(maxSize > 0, "Can't have a cache smaller than one item")
        self.maxSize = maxSize
    }
    
    /**
     Returns the value for a given key if it is in the cache. Also sets it to be last item
     to be kicked from the cache in the event of overflow. If the item is not in the cache,
     returns .None
    */
    open func itemForKey(_ key: Key) -> Value? {
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
    open func setItem(_ val: Value, forKey key:Key) {
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
                hashtable.removeValue(forKey: tail.key)
                removeItemFromList(tail)
            }
        }
    }
    
    // MARK: - private methods
    
    fileprivate func bubbleUp(_ item: ListItem<Key, Value>) {
        guard !(item === head) else { return }
        removeItemFromList(item)
        if let oldHead = head {
            item.nextItem = oldHead
            oldHead.prevItem = item
        } else {
            // list empty, item is also the tail
            tail = item
        }
        item.prevItem = nil
        head = item
    }
    
    fileprivate func removeItemFromList(_ item: ListItem<Key, Value>) {
        if let prev = item.prevItem {
            prev.nextItem = item.nextItem
        }
        if let next = item.nextItem {
            next.prevItem = item.prevItem
        }
        if item === tail {
            tail = item.prevItem
        }
    }
}

/// Sequence operations don't change the structure of the cache like itemForKey and setItem will
extension LRUCache: Sequence {
    public func makeIterator() -> ListItemGenerator<Key, Value> {
        return ListItemGenerator(currentItem: head)
    }
}

extension LRUCache {
    public var descriptionString: String {
        get {
            var acc: [String] = map { return String(describing: $0) }
            acc.append("•")
            return acc.joined(separator: "\n")
        }
    }
}
