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
    public func rx_responseObject(request: NSURLRequest) -> Observable<(NSData, NSHTTPURLResponse)> {
        return Observable.create { observer in

            let task = self.dataTaskWithRequest(request) { (data, response, error) in

                guard let response = response, data = data else {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }

                guard let httpResponse = response as? NSHTTPURLResponse else {
                    observer.on(.Error(RxCocoaURLError.NonHTTPResponse(response: response)))
                    return
                }

                observer.on(.Next(data, httpResponse))
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