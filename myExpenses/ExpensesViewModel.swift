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

    private var _expenses: [ExpenseModel] = []
    var expenses: [ExpenseModel] {
        get {
            return _expenses
        }
    }

    init(sessionId: String) {
        // TODO NSUserDefaultsから取得したほうが良さそう
        self.sessionId = sessionId
    }

    func monthlyExpenses(period: String) {
        //TODO periodは日付型のほうがいいかも
        ExpensesModel.call(period)
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { (model, response) in
                    self.result.value = model.result!
                    self._expenses = model.expenses
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

    func deleteAtIndex(index: Int) {
        let expenseId: String = expenses[index].id

        DeleteExpenseModel.call(expenseId, sessionId: self.sessionId)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { (model, response) in
                    // TODO indexよりもキー項目指定のほうがいいかも
                    self.result.value = model.result!
                    self._expenses.removeAtIndex(index)
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
        fareTotal.value = _expenses.reduce(0) {
            $0 + $1.fare
            }.description
    }
}
