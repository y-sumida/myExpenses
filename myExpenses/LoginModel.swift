//
//  LoginModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/01.
//
//
import Foundation
import RxSwift

class LoginModel {
    static func call(email: String, password: String) -> Observable<(NSData, NSHTTPURLResponse)> {
        let body = NSMutableDictionary()
        body.setValue(email, forKey: "email");
        body.setValue(password, forKey: "password");

        let url:NSURL = NSURL(string: "http://localhost/hoge.php")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))

        let session: NSURLSession = NSURLSession.sharedSession()

        return session.rx_responseObject(request)
    }
}
