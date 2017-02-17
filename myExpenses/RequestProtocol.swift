//
//  RequestProtocol.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/17.
//
//

import Foundation

public protocol RequestProtocol {
    associatedtype Response: ResponseProtocol
    var request: NSMutableURLRequest {get}
    var baseURL: String { get }
    func responseToObject(data: NSData) -> Response
}

extension RequestProtocol {
    var baseURL: String {
        return "http://localhost/"
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

