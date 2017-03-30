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

extension URLSession {
    func rx_responseObject<T: RequestProtocol>(_ request: T) -> Observable<(T.Response, HTTPURLResponse)> {
        showRequestLog(request.request)

        return Observable.create { observer in
            // TODO request.requestを適切な名前にしたい
            let task = self.dataTask(with: request.request as URLRequest) { (data, response, error) in

                guard let response = response, let data = data else {
                    observer.onError(APIResult(code: APIResultCode.UnknownError, message: "サーバーエラーが発生しました") as Error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(APIResult(code: APIResultCode.UnknownError, message: "サーバーエラーが発生しました") as Error)
                    return
                }

                self.showResponseLog(httpResponse, data: data)

                if httpResponse.statusCode >= 400 {
                    observer.onError(APIResult(code: APIResultCode.create("N" + httpResponse.statusCode.description), message: "サーバーエラーが発生しました"))
                    return
                }

                if let object = request.responseToObject(data) {
                    observer.on(.next(object, httpResponse))
                }
                else {
                    observer.onError(APIResult(code: APIResultCode.JSONError, message: "サーバーエラーが発生しました") as Error)
                }
                observer.on(.completed)
            }

            let t = task
            t.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    fileprivate func showRequestLog(_ request: NSMutableURLRequest) {
        print("REQUEST--------------------")
        print("url \((request.url?.absoluteString)!)")
        print("method \(request.httpMethod)")
        if let body: Data = request.httpBody {
            do {
                let object = try JSONSerialization.jsonObject(with: body, options: .mutableContainers) as! NSDictionary

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

    fileprivate func showResponseLog(_ response: HTTPURLResponse, data: Data) {
        print("RESPONSE--------------------")
        print("url \((response.url?.absoluteString))")
        print("status \(response.statusCode)")
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
            print("data \(object)")
        } catch {
            print("dagta empty")
        }
        print("---------------------------")
    }
}
