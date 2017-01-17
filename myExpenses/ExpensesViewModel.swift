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
    var deleteTrigger: PublishSubject<Void> = PublishSubject()
    var reloadTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<ErrorType?> = Variable(nil)
    var fareTotal: Variable<String> = Variable("")
    var sessionId: String = ""

    private var _destinations: [DestinationModel] = []
    var destinations: [DestinationModel] {
        get {
            return _destinations
        }
    }

    init(sessionId: String) {
        // TODO NSUserDefaultsから取得したほうが良さそう
        self.sessionId = sessionId
    }

    func monthlyExpenses(period: String) {
        //TODO periodは日付型のほうがいいかも
        ExpensesModel.call(self.sessionId, period: period)
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { (model, response) in
                    self.result.value = model.result!
                    self._destinations = model.destinations
                    self.calcFareTotal()

                    self.reloadTrigger.onNext(())
                },
                onError: { (error: ErrorType) in
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }

    func deleteDestination(index: Int) {
        let expenseId: String = destinations[index].id

        DeleteExpenseModel.call(expenseId, sessionId: self.sessionId)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { (model, response) in
                    // TODO indexよりもキー項目指定のほうがいいかも
                    self.result.value = model.result!
                    self._destinations.removeAtIndex(index)
                    self.calcFareTotal()

                    self.reloadTrigger.onNext(())
                },
                onError: { (error: ErrorType) in
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }

    private func calcFareTotal() {
        fareTotal.value = _destinations.reduce(0) {
            $0 + $1.fare
            }.description
    }
}
