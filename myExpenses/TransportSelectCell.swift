//
//  TransportSelectCell.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/21.
//
//

import UIKit
import RxSwift


class TransportSelectCell: UITableViewCell {
    @IBOutlet weak var transportName: UILabel!
    @IBOutlet weak var transportSwitch: UISwitch!

    fileprivate var bag: DisposeBag!
    var bindValue: Variable<Bool>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .bindTo(self.transportSwitch.rx.value)
                .addDisposableTo(bag)
            self.transportSwitch.rx.value
                .bindTo(self.bindValue)
                .addDisposableTo(bag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
}
