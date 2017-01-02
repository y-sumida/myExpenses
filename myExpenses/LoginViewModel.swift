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

                    print("email:\(self.email.value)")
                    print("password:\(self.password.value)")
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