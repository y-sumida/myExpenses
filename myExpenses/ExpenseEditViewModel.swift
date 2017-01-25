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
    private var expense: DestinationModel!

    var result: Variable<ErrorType?> = Variable(nil)

    init(expense: DestinationModel = DestinationModel(data: [:])) {
        // 交通費１件分のモデル
        self.expense = expense
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