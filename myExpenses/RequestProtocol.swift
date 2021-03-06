//
//  RequestProtocol.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/17.
//
//

import Foundation

public enum HTTPMethod: String {
    case Get = "GET"
    case Post = "POST"
}

protocol RequestProtocol {
    associatedtype Response: ResponseProtocol
    var request: NSMutableURLRequest {get}
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var body: NSMutableDictionary? { get }
    func responseToObject(_ data: Data) -> Response?
}

extension RequestProtocol {
    var baseURL: String {
        return "http://localhost/"
    }

    var path: String {
        return ""
    }

    var body: NSMutableDictionary? {
        return nil
    }

    var request: NSMutableURLRequest {
        let url:URL = URL(string: baseURL + path)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = self.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let `body`: NSMutableDictionary = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 2))
        }
        return request
    }

    func responseToObject(_ data: Data) -> Response? {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
            return Response(data: object)
        } catch {
            return Response(data: [:])
        }
    }
}

