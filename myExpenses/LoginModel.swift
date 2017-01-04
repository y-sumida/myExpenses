//
//  LoginModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/01.
//
//
import Foundation
import RxSwift

public protocol RequestProtocol {
    associatedtype Response
    var request: NSMutableURLRequest {get}
    func responseToObject(data: NSData) -> Response
}

public protocol ResponseProtocol {
    init(data: NSDictionary)
}

class LoginModel: ResponseProtocol {
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

        if let success = data["success"] {
            self.isSuccess = success as! Bool
        }
    }

    static func call(email: String, password: String) -> Observable<(LoginModel, NSHTTPURLResponse)> {

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(LoginRequest(email: email, password: password))
    }
}

class LoginRequest: RequestProtocol {
    typealias Response = LoginModel
    var email: String = ""
    var password: String = ""

    var request: NSMutableURLRequest {
        let body = NSMutableDictionary()
        body.setValue(email, forKey: "email");
        body.setValue(password, forKey: "password");

        let url:NSURL = NSURL(string: "http://localhost/login.php")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))
        return request
    }

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

    func responseToObject(data: NSData) -> Response {
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
            return Response(data: object)
        } catch {
            return Response(data: [:])
        }
    }
}