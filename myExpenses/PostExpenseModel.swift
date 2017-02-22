//
//  PostExpenseModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/24.
//
//

import Foundation
import RxSwift

class PostExpenseModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""

    required init?(data: NSDictionary) {
        guard let resultCode = data["resultCode"],
            let resultMessage = data["resultMessage"],
            let sessionId = data["sessionId"]
            else { return nil }

        self.resultCode = resultCode as! String
        self.resultMessage = resultMessage as! String
        
        self.sessionId = sessionId as! String
        // セッションID更新
        let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        sharedInstance.setObject(self.sessionId, forKey: "sessionId")
        sharedInstance.synchronize()
        
        result = APIResult(code: self.resultCode, message: self.resultMessage, sessionId: self.sessionId)
    }
    
    static func call(expense: ExpenseModel) -> Observable<(PostExpenseModel, NSHTTPURLResponse)> {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(PostExpenseRequest(expense: expense))
    }
}

struct PostExpenseRequest: RequestProtocol {
    var expense: ExpenseModel!
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

    // RequestProtocol
    typealias Response = PostExpenseModel
    var method: HTTPMethod = .Post
    var path: String = "upsert.php"
    var body: NSMutableDictionary {
        let body = NSMutableDictionary()
        body.setValue(sessionId, forKey: "sessionId")
        body.setValue(expense.dateAsString, forKey: "date")
        body.setValue(expense.name, forKey: "name")
        body.setValue(expense.useJR, forKey: "jr")
        body.setValue(expense.useSubway, forKey: "subway")
        body.setValue(expense.usePrivate, forKey: "private")
        body.setValue(expense.useHighway, forKey: "highway")
        body.setValue(expense.useOther, forKey: "other")
        body.setValue(expense.from, forKey: "from")
        body.setValue(expense.to, forKey: "to")
        body.setValue(expense.fare, forKey: "fare")
        body.setValue(expense.remarks, forKey: "remarks")

        if expense.id.isNotEmpty {
            body.setValue(expense.id, forKey: "id")
        }

        return body
    }

    init(expense: ExpenseModel) {
        self.expense = expense
    }
}