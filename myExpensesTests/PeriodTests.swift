//
//  PeriodTests.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/03/19.
//
//

import XCTest

class PeriodTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test日付のみ() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let period: Period?
        if let date: NSDate = formatter.dateFromString("20170319") {
            period = Period(date: date)
        }
        else {
            period = Period()
        }

        XCTAssertEqual(period?.description, "201703")
    }

    func test日付時分秒() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd hh:mm:ss"
        let period: Period?
        if let date: NSDate = formatter.dateFromString("20170419 10:15:30") {
            period = Period(date: date)
        }
        else {
            period = Period()
        }

        XCTAssertEqual(period?.description, "201704")
    }

    func test日付上限() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd HH:mm:ss"
        let period: Period?
        if let date: NSDate = formatter.dateFromString("20170519 23:59:59") {
            period = Period(date: date)
        }
        else {
            period = Period()
        }

        XCTAssertEqual(period?.description, "201705")
    }

    func test過去半年() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd HH:mm:ss"
        let periods: [Period]?
        if let date: NSDate = formatter.dateFromString("20170519 23:59:59") {
            periods = Period.pastHalfYear(date)
        }
        else {
            periods = Period.pastHalfYear()
        }

        let expected = ["201705", "201704", "201703", "201702", "201701", "201612"]
        let actual = periods?.map { $0.description}

        XCTAssertEqual(actual!, expected)
    }
}