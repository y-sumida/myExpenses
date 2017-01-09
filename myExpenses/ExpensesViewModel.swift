//
//  ExpensesViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/07.
//
//

import Foundation
import RxSwift

class ExpensesViewModel {
    private let bag: DisposeBag = DisposeBag()

    var period: Variable<String> = Variable("")
    var fetchTrigger: PublishSubject<Void> = PublishSubject()
    var reloadTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<ErrorType?> = Variable(nil)
    var desitations: [DestinationModel] = []

    init(sessionId: String) {
        fetchTrigger
            .flatMap {
                ExpensesModel.call(sessionId, period: self.period.value)
            }
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { (model, response) in
                    self.result.value = model.result!
                    self.desitations = model.destinations

                    self.reloadTrigger.onNext(())
                },
                onError: { (error: ErrorType) in
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }
}
