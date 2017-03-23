//
//  ExpenseCellViewModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/09.
//
//

import UIKit
import Foundation
import RxSwift

final class ExpenseCellViewModel {
    var date: Variable<String> = Variable("")
    var destination: Variable<String> = Variable("")
    var fare: Variable<String> = Variable("")

    init(model: ExpenseModel) {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        self.date.value = formatter.string(from: model.date! as Date)

        self.destination.value = model.name

        self.fare.value = model.fare.commaSeparated
    }
}
