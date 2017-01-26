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

class ExpenseCellViewModel {
    var date: Variable<String> = Variable("")
    var destination: Variable<String> = Variable("")
    var fare: Variable<String> = Variable("")

    init(model: ExpenseModel) {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd"
        self.date.value = formatter.stringFromDate(model.date!)

        self.destination.value = model.name

        self.fare.value = model.fare.description
    }
}