//
//  ExpenseEditViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/24.
//
//

import Foundation
import RxSwift

class ExpenseEditViewModel {
    private let bag: DisposeBag = DisposeBag()
    private var expense: ExpenseModel!

    var result: Variable<ErrorType?> = Variable(nil)
    var date: Variable<String> = Variable("")
    var destination: Variable<String> = Variable("")
    var fare: Variable<String> = Variable("")
    var memo: Variable<String> = Variable("")
    var from: Variable<String> = Variable("")
    var to: Variable<String> = Variable("")
    var useOther: Variable<String> = Variable("")
    var useJR: Variable<Bool> = Variable(false)
    var useSubway: Variable<Bool> = Variable(false)
    var usePrivate: Variable<Bool> = Variable(false)
    var useBus: Variable<Bool> = Variable(false)
    var useHighway: Variable<Bool> = Variable(false)

    init(expense: ExpenseModel = ExpenseModel(data: [:])) {
        // 交通費１件分のモデル
        self.expense = expense
        self.date.value = expense.dateAsString
        self.destination.value = expense.name
        self.fare.value = expense.fare.description
        self.memo.value = expense.remarks
        self.from.value = expense.from
        self.to.value = expense.to
        self.useOther.value = expense.useOther
        self.useJR.value = expense.useJR
        self.useSubway.value = expense.useSubway
        self.usePrivate.value = expense.usePrivate
        self.useBus.value = expense.useBus
        self.useHighway.value = expense.useHighway
    }
    
    func upsertExpense() {
        // TODO sessionIDをUserDefaultなどから取得
        PostExpenseModel.call(self.expense, sessionId: "")
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { model, response in
                    self.result.value = model.result
                },
                onError: { (error: ErrorType) in
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }
}