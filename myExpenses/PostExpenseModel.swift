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
    
    static func call(expense: DestinationModel, sessionId: String) -> Observable<(PostExpenseModel, NSHTTPURLResponse)> {
        
        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(PostExpenseRequest(expense: expense, sessionId: sessionId))
    }
}

class PostExpenseRequest: RequestProtocol {
    typealias Response = PostExpenseModel
    var expense: DestinationModel!
    var sessionId: String = ""

    var request: NSMutableURLRequest {
        let body = NSMutableDictionary()
        body.setValue(sessionId, forKey: "sessionId")
        body.setValue(expense.date, forKey: "date")
        body.setValue(expense.name, forKey: "name")
        body.setValue(expense.useJR, forKey: "jr")
        body.setValue(expense.usePrivate, forKey: "private")
        body.setValue(expense.useHighway, forKey: "highway")
        
        let url:NSURL = NSURL(string: baseURL + "upsert.php")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))
        return request
    }
    
    init(expense: DestinationModel, sessionId: String) {
        self.expense = expense
        self.sessionId = sessionId
    }
}