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
        }

        if let expenses = data["destinations"] {
            let arr = expenses as! Array<[String : AnyObject]>
            
            self.expenses = arr.map {
               ExpenseModel(data: $0)
            }
        }

        result = APIResult(code: self.resultCode, message: self.resultMessage)
    }

    static func call(period: Period) -> Observable<(ExpensesModel, NSHTTPURLResponse)> {

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(ExpensesRequest(period: period))
    }
}

class ExpenseModel {
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

    init(data: NSDictionary) {
        if let id = data["id"] {
            self.id = id as! String
        }

        if let date = data["date"] {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMdd"

            if let date: NSDate = formatter.dateFromString(date as! String) {
                self.date = date
                self.dateAsString = formatter.stringFromDate(date)
            }
        }

        if let name = data["name"] {
            self.name = name as! String
        }

        if let useJR = data["jr"] {
            self.useJR = useJR as! Bool
        }

        if let useSubway = data["subway"] {
            self.useJR = useSubway as! Bool
        }

        if let usePrivate = data["private"] {
            self.usePrivate = usePrivate as! Bool
        }

        if let useBus = data["bus"] {
            self.usePrivate = useBus as! Bool
        }

        if let useOther = data["other"] {
            self.useOther = useOther as! String
        }

        if let from = data["from"] {
            self.from = from as! String
        }

        if let to = data["to"] {
            self.to = to as! String
        }

        if let fare = data["fare"] {
            self.fare = fare as! Int
        }

        if let remarks = data["remarks"] {
            self.remarks = remarks as! String
        }
    }
}

class ExpensesRequest: RequestProtocol {
    typealias Response = ExpensesModel
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

    var request: NSMutableURLRequest {
        let url:NSURL = NSURL(string: baseURL + "expenses.php?sessionId=\(sessionId)&period=\(period.description)")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    init(period: Period) {
        self.period = period
    }
}

class Period {
    // TODO 指定した期間のインスタンスを生成できるようにする
    private let date:NSDate!
    private let description: String

    init(date: NSDate) {
        self.date = date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMM"
        description = formatter.stringFromDate(date)
    }
}