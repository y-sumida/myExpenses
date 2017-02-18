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
    var reloadTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<ErrorType?> = Variable(nil)
    var fareTotal: Variable<String> = Variable("")

    private var _expenses: [ExpenseModel] = []
    var expenses: [ExpenseModel] {
        get {
            return _expenses
        }
    }

    init() {}

    func monthlyExpenses(period: Period) {
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

        DeleteExpenseModel.call(expenseId)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { (model, response) in
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

    func searchExpenses(keyword: String) {
        ExpensesModel.call(keyword)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { (model, response) in
                    self.result.value = model.result!
                    self._expenses = model.expenses

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
            }.commaSeparated
    }
}
