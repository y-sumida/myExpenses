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
            let sharedInstance: UserDefaults = UserDefaults.standard
            sharedInstance.set(self.sessionId, forKey: "sessionId")
            sharedInstance.synchronize()
        }

        if let expenses = data["destinations"] {
            let arr = expenses as! Array<[String : AnyObject]>

            arr.forEach {
                if let expense: ExpenseModel = ExpenseModel(data: $0 as NSDictionary) {
                    self.expenses.append(expense)
                }
            }
        }

        result = APIResult(code: APIResultCode.create(self.resultCode), message: self.resultMessage)
    }

    static func call(_ period: Period) -> Observable<(ExpensesModel, HTTPURLResponse)> {

        let session: URLSession = URLSession.shared
        return session.rx_responseObject(ExpensesRequest(period: period))
    }

    static func call(_ keyword: String) -> Observable<(ExpensesModel, HTTPURLResponse)> {
        // 検索キーワード保存
        let sharedInstance: UserDefaults = UserDefaults.standard
        if var searchWords: [String] = sharedInstance.array(forKey: "searchWords") as? [String] {
            searchWords.insert(keyword, at: 0)
            if searchWords.count > 10 {
                searchWords.removeLast()
            }
            sharedInstance.set(searchWords, forKey: "searchWords")
        }
        else {
            sharedInstance.set([keyword], forKey: "searchWords")
        }
        sharedInstance.synchronize()

        let session: URLSession = URLSession.shared
        return session.rx_responseObject(SearchRequest(keyword: keyword))
    }
}

class ExpenseModel {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var id: String = ""
    var date: Date?
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

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if let date: Date = formatter.date(from: date as! String) {
            self.date = date
            self.dateAsString = formatter.string(from: date)
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
            let sharedInstance: UserDefaults = UserDefaults.standard
            if let sessionId: String = sharedInstance.string(forKey: "sessionId") {
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
            let sharedInstance: UserDefaults = UserDefaults.standard
            if let sessionId: String = sharedInstance.string(forKey: "sessionId") {
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
    let date:Date!
    let description: String

    init(date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        formatter.locale = Locale(identifier: "ja_JP")
        description = formatter.string(from: date)
        print(description)

        // 指定した月の月初日を保持
        self.date = formatter.date(from: "\(description)")
        print(self.date)
    }

    // 過去半年分
    static func pastHalfYear(_ date: Date = Date()) -> [Period] {
        let current: Period = Period(date: date as Date)
        var halfYears: [Period] = [current]

        for i in 1...5 {
            // Periodのdateパラメータは月初日なので1時間引くことで前日にする
            let pastDate: Date = Date(timeInterval: -60*60, since: halfYears[i - 1].date)
            halfYears.append(Period(date: pastDate))
        }

        return halfYears
    }
}
