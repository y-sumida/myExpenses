//
//  LoginModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/01.
//
//
import Foundation
import RxSwift

struct APIResult: Error {
    var code: APIResultCode
    var message: String
    var sessionId: String

    init(code: APIResultCode, message: String, sessionId: String = "") {
        self.code = code
        self.message = message
        self.sessionId = sessionId
    }
}

enum APIResultCode: String {
    case Success = "E000"
    case SessionError = "E001" // セッション切れ
    case JSONError = "E002"
    case UnknownError = "E999"

    static func create(_ code: String?) -> APIResultCode {
        return APIResultCode(rawValue: code ?? "") ?? .UnknownError
    }
}

struct LoginModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var isSuccess: Bool = false

    init?(data: NSDictionary) {
        guard let resultCode = data["resultCode"],
            let resultMessage = data["resultMessage"],
            let sessionId = data["sessionId"],
            let success = data["success"]
            else { return nil }

        self.resultCode = resultCode as! String
        self.resultMessage = resultMessage as! String

        self.sessionId = sessionId as! String
        // ログイン成功時にセッションIDを保存
        let sharedInstance: UserDefaults = UserDefaults.standard
        sharedInstance.set(self.sessionId, forKey: "sessionId")
        sharedInstance.synchronize()

        self.isSuccess = success as! Bool

        result = APIResult(code: APIResultCode.create(self.resultCode), message: self.resultMessage, sessionId: self.sessionId)
    }

    static func call(_ email: String, password: String) -> Observable<(LoginModel, HTTPURLResponse)> {
        // メールアドレス保存
        let sharedInstance: UserDefaults = UserDefaults.standard
        sharedInstance.set(email, forKey: "email")
        sharedInstance.synchronize()

        let session: URLSession = URLSession.shared
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
    var body: NSMutableDictionary? {
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
