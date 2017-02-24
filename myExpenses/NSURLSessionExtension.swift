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
    func rx_responseObject<T: RequestProtocol>(request: T) -> Observable<(T.Response, NSHTTPURLResponse)> {
        showRequestLog(request.request)

        return Observable.create { observer in
            // TODO request.requestを適切な名前にしたい
            let task = self.dataTaskWithRequest(request.request) { (data, response, error) in

                guard let response = response, data = data else {
                    observer.onError(APIResult(code: APIResultCode.UnknownError, message: "サーバーエラーが発生しました"))
                    return
                }

                guard let httpResponse = response as? NSHTTPURLResponse else {
                    observer.onError(APIResult(code: APIResultCode.UnknownError, message: "サーバーエラーが発生しました"))
                    return
                }

                self.showResponseLog(httpResponse, data: data)

                if httpResponse.statusCode >= 400 {
                    observer.onError(APIResult(code: APIResultCode.create("N" + httpResponse.statusCode.description), message: "サーバーエラーが発生しました"))
                    return
                }

                if let object = request.responseToObject(data) {
                    observer.on(.Next(object, httpResponse))
                }
                else {
                    observer.onError(APIResult(code: APIResultCode.JSONError, message: "サーバーエラーが発生しました"))
                }
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