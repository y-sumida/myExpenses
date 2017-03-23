//
//  ExpensesViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/07.
//
//

import Foundation
import RxSwift

final class ExpensesViewModel {
    fileprivate let bag: DisposeBag = DisposeBag()

    var period: Variable<String> = Variable("")
    var reloadTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<Error?> = Variable(nil)
    var fareTotal: Variable<String> = Variable("")

    fileprivate(set) var expenses: [ExpenseModel] = []

    init() {}

    func monthlyExpenses(_ period: Period) {
        ExpensesModel.call(period)
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { [weak self] (model, response) in
                    guard let `self` = self else { return }
                    self.result.value = model.result!
                    self.expenses = model.expenses
                    self.calcFareTotal()

                    self.reloadTrigger.onNext(())
                },
                onError: { [weak self] (error: Error) in
                    guard let `self` = self else { return }
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }

    func deleteAtIndex(_ index: Int) {
        let expenseId: String = expenses[index].id

        DeleteExpenseModel.call(expenseId)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (model, response) in
                    guard let `self` = self else { return }
                    self.result.value = model.result!
                    self.expenses.remove(at: index)
                    self.calcFareTotal()

                    self.reloadTrigger.onNext(())
                },
                onError: { [weak self] (error: Error) in
                    guard let `self` = self else { return }
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }

    func searchExpenses(_ keyword: String) {
        ExpensesModel.call(keyword)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (model, response) in
                    guard let `self` = self else { return }
                    self.result.value = model.result!
                    self.expenses = model.expenses

                    self.reloadTrigger.onNext(())
                },
                onError: { [weak self] (error: Error) in
                    guard let `self` = self else { return }
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }

    fileprivate func calcFareTotal() {
        fareTotal.value = expenses.reduce(0) {
            $0 + $1.fare
            }.commaSeparated
    }
}
