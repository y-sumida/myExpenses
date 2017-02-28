//
//  ExpensesModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/07.
//
//

import Foundation
import RxSwift

class ExpensesModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var expenses: [ExpenseModel] = []

    required init(data: NSDictionary) {
        if let resultCode = data["resultCode"] {
            self.resultCode = resultCode as! String
        }

        if let resultMessage = data["resultMessage"] {
            self.resultMessage = resultMessage as! String
        }

        if let sessionId = data["sessionId"] {
            self.sessionId = sessionId as! String
            // セッションID更新
            let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            sharedInstance.setObject(self.sessionId, forKey: "sessionId")
            sharedInstance.synchronize()
        }

        if let expenses = data["destinations"] {
            let arr = expenses as! Array<[String : AnyObject]>

            arr.forEach {
                if let expense: ExpenseModel = ExpenseModel(data: $0) {
                    self.expenses.append(expense)
                }
            }
        }

        result = APIResult(code: APIResultCode.create(self.resultCode), message: self.resultMessage)
    }

    static func call(period: Period) -> Observable<(ExpensesModel, NSHTTPURLResponse)> {

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(ExpensesRequest(period: period))
    }

    static func call(keyword: String) -> Observable<(ExpensesModel, NSHTTPURLResponse)> {
        // 検索キーワード保存
        let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if var searchWords: [String] = sharedInstance.arrayForKey("searchWords") as? [String] {
            searchWords.insert(keyword, atIndex: 0)
            if searchWords.count > 10 {
                searchWords.removeLast()
            }
            sharedInstance.setObject(searchWords, forKey: "searchWords")
        }
        else {
            sharedInstance.setObject([keyword], forKey: "searchWords")
        }
        sharedInstance.synchronize()

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(SearchRequest(keyword: keyword))
    }
}

class ExpenseModel {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var id: String = ""
    var date: NSDate?
    var dateAsString: String = ""
    var name: String = ""
    var useJR: Bool = false
    var useSubway: Bool = false
    var usePrivate: Bool = false
    var useHighway: Bool = false
    var useBus: Bool = false
    var useOther: String = ""
    var from: String = ""
    var to: String = ""
    var fare: Int = 0
    var remarks: String = ""

    init?(data: NSDictionary) {
        guard let id = data["id"],
            let date = data["date"],
            let name = data["name"],
            let useJR = data["jr"],
            let useSubway = data["subway"],
            let usePrivate = data["private"],
            let useBus = data["bus"],
            let useOther = data["other"],
            let from = data["from"],
            let to = data["to"],
            let fare = data["fare"],
            let remarks = data["remarks"]
            else { return nil }

        self.id = id as! String

        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if let date: NSDate = formatter.dateFromString(date as! String) {
            self.date = date
            self.dateAsString = formatter.stringFromDate(date)
        }
        else {
            return nil
        }

        self.name = name as! String
        self.useJR = useJR as! Bool
        self.useSubway = useSubway as! Bool
        self.usePrivate = usePrivate as! Bool
        self.usePrivate = useBus as! Bool
        self.useOther = useOther as! String
        self.from = from as! String
        self.to = to as! String
        self.fare = fare as! Int
        self.remarks = remarks as! String
        
    }

    // 新規作成時用
    init() {}
}

struct ExpensesRequest: RequestProtocol {
    typealias Response = ExpensesModel
    var method: HTTPMethod = .Get
    var path: String {
        return "expenses.php?sessionId=\(sessionId)&period=\(period.description)"
    }
    private var sessionId: String {
        get {
            let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let sessionId: String = sharedInstance.stringForKey("sessionId") {
                return sessionId
            }
            else {
                return ""
            }
        }
    }
    private let period: Period!

    init(period: Period) {
        self.period = period
    }
}

class SearchRequest: RequestProtocol {
    private var sessionId: String {
        get {
            let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let sessionId: String = sharedInstance.stringForKey("sessionId") {
                return sessionId
            }
            else {
                return ""
            }
        }
    }
    private let keyword: String

    // RequestProtocol
    typealias Response = ExpensesModel
    var method: HTTPMethod = .Get
    var path: String {
        return "search.php?sessionId=\(sessionId)&keyword=\(keyword)"
    }

    init(keyword: String) {
        self.keyword = keyword
    }
}

struct Period {
    let date:NSDate!
    let description: String

    init(date: NSDate = NSDate()) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMM"
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        description = formatter.stringFromDate(date)
        print(description)

        // 指定した月の月初日を保持
        self.date = formatter.dateFromString("\(description)")
        print(self.date)
    }

    // 過去半年分
    static func pastHalfYear() -> [Period] {
        let current: Period = Period(date: NSDate())
        var halfYears: [Period] = [current]

        for i in 1...5 {
            // Periodのdateパラメータは月初日なので1時間引くことで前日にする
            let pastDate: NSDate = NSDate(timeInterval: -60*60, sinceDate: halfYears[i - 1].date)
            halfYears.append(Period(date: pastDate))
        }

        return halfYears
    }
}