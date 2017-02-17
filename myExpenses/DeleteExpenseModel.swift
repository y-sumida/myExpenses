//
//  DeleteExpenseModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/15.
//
//

import Foundation
import RxSwift

class DeleteExpenseModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var isSuccess: Bool = false

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

        result = APIResult(code: self.resultCode, message: self.resultMessage, sessionId: self.sessionId)
    }

    static func call(expenseId: String) -> Observable<(DeleteExpenseModel, NSHTTPURLResponse)> {

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(DeleteExpenseRequest(expenseId: expenseId))
    }
}

struct DeleteExpenseRequest: RequestProtocol {
    private var expenseId: String = ""
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
    typealias Response = DeleteExpenseModel
    var method: HTTPMethod = .Post
    var path: String = "delete.php"
    var body: NSMutableDictionary {
        let body = NSMutableDictionary()
        body.setValue(expenseId, forKey: "id");
        body.setValue(sessionId, forKey: "sessionId");
        return body
    }

    var request: NSMutableURLRequest {
        let url:NSURL = NSURL(string: baseURL + path)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = self.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(self.body, options: NSJSONWritingOptions.init(rawValue: 2))
        return request
    }

    init(expenseId: String) {
        self.expenseId = expenseId
    }
}
