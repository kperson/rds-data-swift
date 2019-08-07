import XCTest

import RDSDataTests

var tests = [XCTestCaseEntry]()
tests += RDSDataTests.__allTests()

XCTMain(tests)
