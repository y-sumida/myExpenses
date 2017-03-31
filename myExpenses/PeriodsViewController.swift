//
//  PeriodsViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/03.
//
//

import UIKit

class PeriodsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    private var periods: [Period]!

    var handler: ((_ period: Period) -> Void) = {_ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self

        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        periods = Period.pastHalfYear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO 表示書式調整
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = periods[indexPath.row].description

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.handler(periods[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
