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
    var result: Variable<ErrorType?> = Variable(nil)

    init() {
        loginTrigger
            .flatMap {
                LoginModel.call(self.email.value, password: self.password.value)
            }
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { (model, response) in
                    self.result.value = model.result!
                },
                onError: { (error: ErrorType) in
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }
}