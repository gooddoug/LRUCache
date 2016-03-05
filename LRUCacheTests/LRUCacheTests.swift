//
//  LRUCacheTests.swift
//  LRUCacheTests
//
//  Created by Doug Whitmore on 3/4/16.
//  Copyright © 2016 Good Doug. All rights reserved.
//

import XCTest

typealias StringStringCache = LRUCache<String, String>
typealias StringIntCache = LRUCache<String, Int>
typealias URLStringCache = LRUCache<NSURL, String>

class LRUCacheTests: XCTestCase {
    
    func testCreate() {
        let stringInt = LRUCache<String, Int>(maxSize: 1)
        let stringString = StringStringCache(maxSize: 100)
        let urlString = URLStringCache(maxSize: 10)
    }
    
    func testGetAbsentKey() {
        let testKey = "test"
        let testValue = 1
        let stringInt = StringIntCache(maxSize: 1)
        XCTAssertNil(stringInt.itemForKey(testKey))
    }
    
    func testSetKey() {
        let testKey = "test"
        let testValue = 1
        let stringInt = StringIntCache(maxSize: 1)
        stringInt.setItem(testValue, forKey: testKey)
    }
    
    func testSetAndGetItem() {
        let testKey = "test"
        let testValue = 1
        let stringInt = StringIntCache(maxSize: 1)
        stringInt.setItem(testValue, forKey: testKey)
        let item = stringInt.itemForKey(testKey)
        XCTAssertNotNil(item)
        XCTAssert(item! == testValue)
    }
    
    func testOverflow() {
        let testKey1 = "test1"
        let testValue1 = 1
        let testKey2 = "test2"
        let testValue2 = 2
        let stringInt = StringIntCache(maxSize: 1)
        stringInt.setItem(testValue1, forKey: testKey1)
        var item = stringInt.itemForKey(testKey1)
        XCTAssertNotNil(item)
        stringInt.setItem(testValue2, forKey: testKey2)
        item = stringInt.itemForKey(testKey1)
        XCTAssertNil(item)
        item = stringInt.itemForKey(testKey2)
        XCTAssertNotNil(item)
        XCTAssert(item! == testValue2)
    }
    
    func testOverflow2() {
        let testKey1 = "test1"
        let testValue1 = 1
        let testKey2 = "test2"
        let testValue2 = 2
        let testKey3 = "test3"
        let testValue3 = 3
        let maxSize = 2
        let stringInt = StringIntCache(maxSize: maxSize)
        stringInt.setItem(testValue1, forKey: testKey1)
        stringInt.setItem(testValue2, forKey: testKey2)
        stringInt.setItem(testValue3, forKey: testKey3)
        var item = stringInt.itemForKey(testKey1)
        XCTAssertNil(item)
        item = stringInt.itemForKey(testKey2)
        XCTAssertNotNil(item)
        XCTAssert(item! == testValue2)
        XCTAssert(stringInt.count <= maxSize)
    }
    
    func testMutateValue() {
        let testKey1 = "test1"
        let testValue1 = 1
        let testKey2 = "test2"
        let testValue2 = 2
        let changedValue = 12
        llet maxSize = 2
        let stringInt = StringIntCache(maxSize: maxSize)
        stringInt.setItem(testValue1, forKey: testKey1)
        var item = stringInt.itemForKey(testKey1)
        XCTAssertNotNil(item)
        XCTAssert(item! == testValue1)
        stringInt.setItem(testValue2, forKey: testKey2)
        stringInt.setItem(changedValue, forKey: testKey1)
        item = stringInt.itemForKey(testKey1)
        XCTAssertNotNil(item)
        XCTAssert(item! == changedValue)
        print(stringInt.descriptionString)
        XCTAssert(stringInt.count <= maxSize)
    }
}
