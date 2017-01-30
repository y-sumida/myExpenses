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

    var handler: ((date: NSDate) -> Void) = {_ in }

    private var bag: DisposeBag!
    var bindValue: Variable<NSDate>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .bindTo(self.datePicker.rx_date)
                .addDisposableTo(bag)
            self.datePicker.rx_date
                .bindTo(self.bindValue)
                .addDisposableTo(bag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = UIDatePickerMode.Date
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .None
    }
    
    @IBAction func tapDoneButton(sender: AnyObject) {
        handler(date: datePicker.date)
    }
}
