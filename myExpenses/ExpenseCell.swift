//
//  ExpenseCell.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/09.
//
//

import UIKit

class ExpenseCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var fare: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
