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

    init?(data: NSDictionary) {
        guard let resultCode = data["resultCode"],
            let resultMessage = data["resultMessage"],
            let success = data["success"]
            else { return nil }

        self.resultCode = resultCode as! String
        self.resultMessage = resultMessage as! String
        self.isSuccess = success as! Bool

        result = APIResult(code: APIResultCode.create(self.resultCode), message: self.resultMessage)
    }

    static func call() -> Observable<(LogoutModel, HTTPURLResponse)> {
        // sessionId破棄
        let sharedInstance: UserDefaults = UserDefaults.standard
        sharedInstance.removeObject(forKey: "sessionId")

        let session: URLSession = URLSession.shared
        return session.rx_responseObject(LogoutRequest())
    }
}

struct LogoutRequest: RequestProtocol {
    fileprivate var sessionId: String {
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
    typealias Response = LogoutModel
    var method: HTTPMethod = .Post
    var path: String = "logout.php"
    var body: NSMutableDictionary? {
        let body = NSMutableDictionary()
        body.setValue(sessionId, forKey: "sessionId");
        return body
    }

    init() {}
}
