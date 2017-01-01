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
        let url:NSURL = NSURL(string: "http://localhost")!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let session: NSURLSession = NSURLSession.sharedSession()

        return session.rx_response(request)
    }
}
