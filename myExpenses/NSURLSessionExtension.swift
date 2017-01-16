//
//  NSURLSessionExtension.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/02.
//
//

import Foundation
import RxSwift
import RxCocoa

extension NSURLSession {
    public func rx_responseObject<T: RequestProtocol>(request: T) -> Observable<(T.Response, NSHTTPURLResponse)> {
        showRequestLog(request.request)

        return Observable.create { observer in
            let task = self.dataTaskWithRequest(request.request) { (data, response, error) in

                guard let response = response, data = data else {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }

                guard let httpResponse = response as? NSHTTPURLResponse else {
                    observer.on(.Error(RxCocoaURLError.NonHTTPResponse(response: response)))
                    return
                }

                self.showResponseLog(httpResponse, data: data)

                if httpResponse.statusCode >= 400 {
                    observer.onError(APIResult(code: "N" + httpResponse.statusCode.description, message: "サーバーエラーが発生しました"))
                    return
                }

                let object = request.responseToObject(data)
                observer.on(.Next(object, httpResponse))
                observer.on(.Completed)
            }

            let t = task
            t.resume()

            return AnonymousDisposable {
                task.cancel()
            }
        }
    }

    private func showRequestLog(request: NSMutableURLRequest) {
        print("REQUEST--------------------")
        print("url \((request.URL?.absoluteString)!)")
        print("method \(request.HTTPMethod)")
        if let body: NSData = request.HTTPBody {
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(body, options: .MutableContainers) as! NSDictionary
                print("body \(object)")
            } catch {
                print("body empty")
            }
        }
        else {
            print("body empty")
        }
        print("---------------------------")
    }

    private func showResponseLog(response: NSHTTPURLResponse, data: NSData) {
        print("RESPONSE--------------------")
        print("url \((response.URL?.absoluteString))")
        print("status \(response.statusCode)")
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
            print("data \(object)")
        } catch {
            print("dagta empty")
        }
        print("---------------------------")
    }
}