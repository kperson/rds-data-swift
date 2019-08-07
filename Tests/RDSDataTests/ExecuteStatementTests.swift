//
//  RDSDataClient.swift
//  AWSSDKSwiftCore
//
//  Created by Kelton Person on 8/5/19.
//

import XCTest
@testable import RDSData


public class ExecuteStatementTests: XCTestCase {
    
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    func testEncodeString() {
        let val = Field.string("hello")
        let valJSON = try! String(data: jsonEncoder.encode(val), encoding: .utf8)!
        let expected = "{\"stringValue\":\"hello\"}"
        XCTAssertEqual(expected, valJSON)
    }
    
    func testDecodeString() {
        let data = "{\"stringValue\":\"hello\"}".data(using: .utf8)!
        let val = try! jsonDecoder.decode(Field.self, from: data)
        XCTAssertEqual(Field.string("hello"), val)
    }
    
    func testEncodeBool() {
        let val = Field.bool(true)
        let valJSON = try! String(data: jsonEncoder.encode(val), encoding: .utf8)!
        let expected = "{\"booleanValue\":true}"
        XCTAssertEqual(expected, valJSON)
    }
    
    func testDecodeBool() {
        let data = "{\"booleanValue\":true}".data(using: .utf8)!
        let val = try! jsonDecoder.decode(Field.self, from: data)
        XCTAssertEqual(Field.bool(true), val)
    }
    
    func testEncodeDouble() {
        let val = Field.double(25.34)
        let valJSON = try! String(data: jsonEncoder.encode(val), encoding: .utf8)!
        let expected = "{\"doubleValue\":25.34}"
        XCTAssertEqual(expected, valJSON)
    }
    
    func testDecodeDouble() {
        let data = "{\"doubleValue\":25.34}".data(using: .utf8)!
        let val = try! jsonDecoder.decode(Field.self, from: data)
        XCTAssertEqual(Field.double(25.34), val)
    }
    
    func testEncodeIsNull() {
        let val = Field.isNull(false)
        let valJSON = try! String(data: jsonEncoder.encode(val), encoding: .utf8)!
        let expected = "{\"isNull\":false}"
        XCTAssertEqual(expected, valJSON)
    }
    
    func testDecodeIsNull() {
        let data = "{\"isNull\":false}".data(using: .utf8)!
        let val = try! jsonDecoder.decode(Field.self, from: data)
        XCTAssertEqual(Field.isNull(false), val)
    }
    
    func testEncodeLong() {
        let val = Field.long(450)
        let valJSON = try! String(data: jsonEncoder.encode(val), encoding: .utf8)!
        let expected = "{\"longValue\":450}"
        XCTAssertEqual(expected, valJSON)
    }
    
    func testDecodeLong() {
        let data = "{\"longValue\":450}".data(using: .utf8)!
        let val = try! jsonDecoder.decode(Field.self, from: data)
        XCTAssertEqual(Field.long(450), val)
    }

}
