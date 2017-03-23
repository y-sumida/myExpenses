//
//  DatePickerCell.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/23.
//
//

import UIKit
import RxSwift

class DatePickerCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!

    var handler: ((_ date: Date) -> Void) = {_ in }

    fileprivate var bag: DisposeBag!
    var bindValue: Variable<Date>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .bindTo(self.datePicker.rx.date)
                .addDisposableTo(bag)
            self.datePicker.rx.date
                .bindTo(self.bindValue)
                .addDisposableTo(bag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = UIDatePickerMode.date
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    @IBAction func tapDoneButton(_ sender: AnyObject) {
        handler(datePicker.date)
    }
}
