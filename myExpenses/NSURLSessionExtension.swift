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
    public func rx_responseObject(request: NSURLRequest) -> Observable<(NSDictionary, NSHTTPURLResponse)> {
        return Observable.create { observer in

            //TODO NSDictionaryではなくモデルクラスを返したい
            let task = self.dataTaskWithRequest(request) { (data, response, error) in

                guard let response = response, data = data else {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }

                guard let httpResponse = response as? NSHTTPURLResponse else {
                    observer.on(.Error(RxCocoaURLError.NonHTTPResponse(response: response)))
                    return
                }

                do {
                    let object = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
                    observer.on(.Next(object, httpResponse))
                } catch {
                    observer.on(.Next([:], httpResponse))
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

    public func rx_responseObject2<T: RequestProtocol>(request: T) -> Observable<(T.Response, NSHTTPURLResponse)> {
        return Observable.create { observer in

            //TODO NSDictionaryではなくモデルクラスを返したい
            let task = self.dataTaskWithRequest(request.request) { (data, response, error) in

                guard let response = response, data = data else {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }

                guard let httpResponse = response as? NSHTTPURLResponse else {
                    observer.on(.Error(RxCocoaURLError.NonHTTPResponse(response: response)))
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
}