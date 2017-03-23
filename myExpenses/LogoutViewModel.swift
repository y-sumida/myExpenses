//
//  LogoutViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/21.
//
//

import Foundation
import RxSwift

final class LogoutViewModel {
    fileprivate let bag: DisposeBag = DisposeBag()

    var logoutTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<Error?> = Variable(nil)

    init() {
        logoutTrigger
            .flatMap {
                LogoutModel.call()
            }
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { [weak self] (model, response) in
                    guard let `self` = self else { return }
                    self.result.value = model.result!
                },
                onError: { [weak self] (error: Error) in
                    guard let `self` = self else { return }
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }
}
