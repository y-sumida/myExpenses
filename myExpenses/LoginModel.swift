//
//  LoginModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/01.
//
//
import Foundation
import RxSwift

struct APIResult: ErrorType {
    var code: String
    var message: String
    var sessionId: String

    init(code: String, message: String, sessionId: String = "") {
        self.code = code
        self.message = message
        self.sessionId = sessionId
    }
}

enum APIResultCode: String {
    // TODO エラー時の結果コード
    case Success = "E000"
    case SessionError = "E001" // セッション切れ
}

struct LoginModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var isSuccess: Bool = false

    init(data: NSDictionary) {
        if let resultCode = data["resultCode"] {
            self.resultCode = resultCode as! String
        }

        if let resultMessage = data["resultMessage"] {
            self.resultMessage = resultMessage as! String
        }

        if let sessionId = data["sessionId"] {
            self.sessionId = sessionId as! String
            // ログイン成功時にセッションIDを保存
            let sharedInstance: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            sharedInstance.setObject(self.sessionId, forKey: "sessionId")
            sharedInstance.synchronize()
        }

        if let success = data["success"] {
            self.isSuccess = success as! Bool
        }

        result = APIResult(code: self.resultCode, message: self.resultMessage, sessionId: self.sessionId)
    }

    static func call(email: String, password: String) -> Observable<(LoginModel, NSHTTPURLResponse)> {

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(LoginRequest(email: email, password: password))
    }
}

struct LoginRequest: RequestProtocol {
    var email: String = ""
    var password: String = ""

    // RequestProtocol
    typealias Response = LoginModel
    var method: HTTPMethod = .Post
    var path: String = "login.php"
    var body: NSMutableDictionary {
        let body = NSMutableDictionary()
        body.setValue(email, forKey: "email");
        body.setValue(password, forKey: "password");
        return body
    }

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}