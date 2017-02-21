//
//  LogoutModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/21.
//
//

import Foundation
import RxSwift

struct LogoutModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var isSuccess: Bool = false

    init(data: NSDictionary) {
        if let resultCode = data["resultCode"] {
            self.resultCode = resultCode as! String
        }

        if let resultMessage = data["resultMessage"] {
            self.resultMessage = resultMessage as! String
        }

        if let success = data["success"] {
            self.isSuccess = success as! Bool
        }

        result = APIResult(code: self.resultCode, message: self.resultMessage)
    }

    static func call() -> Observable<(LogoutModel, NSHTTPURLResponse)> {
        // sessionId破棄
        let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        sharedInstance.removeObjectForKey("sessionId")

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(LogoutRequest())
    }
}

struct LogoutRequest: RequestProtocol {
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
    typealias Response = LogoutModel
    var method: HTTPMethod = .Post
    var path: String = "logout.php"
    var body: NSMutableDictionary {
        let body = NSMutableDictionary()
        body.setValue(sessionId, forKey: "sessionId");
        return body
    }

    init() {}
}