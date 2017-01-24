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

    var finishTrigger: PublishSubject<Void> = PublishSubject()
    var result: Variable<ErrorType?> = Variable(nil)

    init(expense: DestinationModel) {
        // 交通費１件分のモデル
    }
    
    func upsertExpense() {
        PostExpenseModel.call(self.expense, sessionId: "")
            .observeOn(MainScheduler.instance)//これ以降メインスレッドで実行
            .subscribe(
                onNext: { _ in
                    self.finishTrigger.onNext(())
                },
                onError: { (error: ErrorType) in
                    // APIエラー
                    self.result.value = error
                }
            )
            .addDisposableTo(bag)
    }
}