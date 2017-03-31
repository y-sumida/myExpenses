//
//  DeleteExpenseModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/15.
//
//

import Foundation
import RxSwift

struct DeleteExpenseModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var isSuccess: Bool = false

    init?(data: NSDictionary) {
        guard let resultCode = data["resultCode"],
            let resultMessage = data["resultMessage"],
            let sessionId = data["sessionId"]
            else { return nil }

        self.resultCode = resultCode as! String
        self.resultMessage = resultMessage as! String

        self.sessionId = sessionId as! String
        // セッションID更新
        let sharedInstance: UserDefaults = UserDefaults.standard
        sharedInstance.set(self.sessionId, forKey: "sessionId")
        sharedInstance.synchronize()

        result = APIResult(code: APIResultCode.create(self.resultCode), message: self.resultMessage, sessionId: self.sessionId)
    }

    static func call(_ expenseId: String) -> Observable<(DeleteExpenseModel, HTTPURLResponse)> {

        let session: URLSession = URLSession.shared
        return session.rx_responseObject(DeleteExpenseRequest(expenseId: expenseId))
    }
}

struct DeleteExpenseRequest: RequestProtocol {
    private var expenseId: String = ""
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

    // RequestProtocol
    typealias Response = DeleteExpenseModel
    var method: HTTPMethod = .Post
    var path: String = "delete.php"
    var body: NSMutableDictionary? {
        let body = NSMutableDictionary()
        body.setValue(expenseId, forKey: "id");
        body.setValue(sessionId, forKey: "sessionId");
        return body
    }

    init(expenseId: String) {
        self.expenseId = expenseId
    }
}
