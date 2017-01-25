//
//  DatePickerCell.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/23.
//
//

import UIKit

class DatePickerCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!

    var handler: ((date: String) -> Void) = {_ in }

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = UIDatePickerMode.Date
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .None
    }
    
    @IBAction func tapDoneButton(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat  = "yyyy/MM/dd";
        print(dateFormatter.stringFromDate(datePicker.date))
        handler(date: dateFormatter.stringFromDate(datePicker.date))
    }
}
