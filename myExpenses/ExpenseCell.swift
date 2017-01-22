//
//  ExpenseCell.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/09.
//
//

import UIKit
import RxSwift
import RxCocoa

class ExpenseCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var fare: UILabel!

    var viewModel: ExpenseCellViewModel! {
        didSet {
            self.configure()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    private func configure() {
        let bag: DisposeBag = DisposeBag()

        viewModel.date.asObservable()
            .bindTo(date.rx_text)
            .addDisposableTo(bag)

        viewModel.destination.asObservable()
            .bindTo(destination.rx_text)
            .addDisposableTo(bag)

        viewModel.fare.asObservable()
            .bindTo(fare.rx_text)
            .addDisposableTo(bag)
    }
}
