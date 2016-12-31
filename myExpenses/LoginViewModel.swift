//
//  LoginViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2016/12/31.
//
//

import RxSwift

class LoginViewModel {
    private let bag: DisposeBag = DisposeBag()

    var email: Variable<String> = Variable("")
    var password: Variable<String> = Variable("")
    var loginTrigger: PublishSubject<Void> = PublishSubject()
    var resultTrigger: PublishSubject<Void> = PublishSubject()

    init() {
        loginTrigger.subscribeNext {
            print("email:\(self.email.value)")
            print("password:\(self.password.value)")
            // TODO APIコール
            // ログイン成功時
            self.resultTrigger.onNext(())
            // TODO 失敗時
        }
        .addDisposableTo(bag)
    }
}