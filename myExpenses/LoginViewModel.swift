//
//  LoginViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import Foundation
import RxSwift

class LoginViewModel {
    private let bag: DisposeBag = DisposeBag()

    var email: Variable<String> = Variable("")
    var password: Variable<String> = Variable("")
    var loginTrigger: PublishSubject<Void> = PublishSubject()
    var resultTrigger: PublishSubject<Void> = PublishSubject()

    init() {
        loginTrigger
            .flatMap {
                LoginModel.call(self.email.value, password: self.password.value)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { (data, response) in
                    // ログイン成功
                    dump(data)
                    dump(response)

                    let result = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
                    print(result)
                    self.resultTrigger.onNext(())
                },
                onError: { (error: ErrorType) in
                    // ログイン失敗
                    self.resultTrigger.onError(error)
                }
            )
            .addDisposableTo(bag)
    }
}