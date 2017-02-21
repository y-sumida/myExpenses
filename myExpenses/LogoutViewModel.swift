//
//  LogoutViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/21.
//
//

import Foundation
import RxSwift

class LogoutViewModel {
    private let bag: DisposeBag = DisposeBag()

    var logoutTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<ErrorType?> = Variable(nil)

    init() {
        logoutTrigger
            .flatMap {
                LogoutModel.call()
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