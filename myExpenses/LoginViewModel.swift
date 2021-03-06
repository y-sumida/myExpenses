//
//  LoginViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import Foundation
import RxSwift

final class LoginViewModel {
    private let bag: DisposeBag = DisposeBag()

    var email: Variable<String> = Variable("")
    var password: Variable<String> = Variable("")
    var loginTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<Error?> = Variable(nil)

    init() {
        configureTrigger()
    }

    private func configureTrigger() {
        loginTrigger
            .flatMap {
                LoginModel.call(self.email.value, password: self.password.value)
            }
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { (model, response) in
                    self.result.value = model.result!
                },
                onError: { (error: Error) in
                    // APIエラー
                    self.result.value = error
                    self.configureTrigger() //エラーのあともstreamが流れるように
                }
            )
            .addDisposableTo(bag)
    }
}
