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
        }

        result = APIResult(code: self.resultCode, message: self.resultMessage, sessionId: self.sessionId)
    }

    static func call(expenseId: String, sessionId: String) -> Observable<(DeleteExpenseModel, NSHTTPURLResponse)> {

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(DeleteExpenseRequest(expenseId: expenseId, sessionId: sessionId))
    }
}

class DeleteExpenseRequest: RequestProtocol {
    typealias Response = DeleteExpenseModel
    var expenseId: String = ""
    var sessionId: String = ""

    var request: NSMutableURLRequest {
        let body = NSMutableDictionary()
        body.setValue(expenseId, forKey: "id");
        body.setValue(sessionId, forKey: "sessionId");

        let url:NSURL = NSURL(string: baseURL + "delete.php")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))
        return request
    }

    init(expenseId: String, sessionId: String) {
        self.expenseId = expenseId
        self.sessionId = sessionId
    }
}
