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
typealias IntStringCache = LRUCache<Int, String>
typealias URLStringCache = LRUCache<URL, String>

class LRUCacheTests: XCTestCase {
    
    let debugPrinting = true
    func debugPrint(_ item: String) {
        if debugPrinting {
            print(item)
        }
    }
    
    func testCreate() {
        let stringInt = LRUCache<String, Int>(maxSize: 1)
        XCTAssertNotNil(stringInt)
        let stringString = StringStringCache(maxSize: 100)
        XCTAssertNotNil(stringString)
        let urlString = URLStringCache(maxSize: 10)
        XCTAssertNotNil(urlString)
        let intString = IntStringCache(maxSize: 1)
        XCTAssertNotNil(intString)
    }
    
//    func testBadCreate() {
//        let strinInt = StringIntCache(maxSize: 0)
//    }
    
    func testGetAbsentKey() {
        let testKey = "test"
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
        let maxSize: UInt = 2
        let stringInt = StringIntCache(maxSize: maxSize)
        stringInt.setItem(testValue1, forKey: testKey1)
        stringInt.setItem(testValue2, forKey: testKey2)
        stringInt.setItem(testValue3, forKey: testKey3)
        var item = stringInt.itemForKey(testKey1)
        XCTAssertNil(item)
        item = stringInt.itemForKey(testKey2)
        XCTAssertNotNil(item)
        XCTAssert(item! == testValue2)
        XCTAssert(stringInt.size <= maxSize)
    }
    
    func testMutateValue() {
        let testKey1 = "test1"
        let testValue1 = 1
        let testKey2 = "test2"
        let testValue2 = 2
        let changedValue = 12
        let maxSize: UInt = 2
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
        debugPrint(stringInt.descriptionString)
        XCTAssert(stringInt.size <= maxSize)
    }
    
    func testRightThingGetsKickedFromCache() {
        let testKey1 = "test1"
        let testValue1 = 1
        let testKey2 = "test2"
        let testValue2 = 2
        let testKey3 = "test3"
        let testValue3 = 3
        let maxSize: UInt = 2
        let stringInt = StringIntCache(maxSize: maxSize)
        stringInt.setItem(testValue1, forKey: testKey1)
        stringInt.setItem(testValue2, forKey: testKey2)
        let item = stringInt.itemForKey(testKey1)
        XCTAssertNotNil(item)
        stringInt.setItem(testValue3, forKey: testKey3)
        let shouldBeNil = stringInt.itemForKey(testKey2)
        XCTAssertNil(shouldBeNil)
        debugPrint(stringInt.descriptionString)
        XCTAssert(stringInt.size <= maxSize)
        debugPrint("count: \(stringInt.size)")
    }
    
    func testSizedCache() {
        let testKey1 = "test1"
        let testKey2 = "test2"
        let testKey3 = "test3"
        let stringInt = StringIntCache(maxSize: 4)
        stringInt.sizeOfItem = { item in
            return UInt(item)
        }
        stringInt.setItem(1, forKey: testKey1)
        stringInt.setItem(2, forKey: testKey2)
        var val1 = stringInt.itemForKey(testKey1)
        XCTAssertNotNil(val1)
        XCTAssertEqual(val1, 1)
        XCTAssertEqual(stringInt.size, 3)
        stringInt.setItem(3, forKey: testKey3)
        val1 = stringInt.itemForKey(testKey1)
        XCTAssertNotNil(val1)
        XCTAssertEqual(val1, 1)
        XCTAssertEqual(stringInt.size, 4)
    }
    
    func testValueTooBig() {
        let testKey = "test1"
        let stringInt = StringIntCache(maxSize: 4)
        stringInt.sizeOfItem = { item in
            return UInt(item)
        }
        stringInt.setItem(5, forKey: testKey)
        let val = stringInt.itemForKey(testKey)
        XCTAssertNotNil(val)
        XCTAssertEqual(val, 5)
    }
}
