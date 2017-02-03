//
//  PeriodSelectViewController.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/03.
//
//

import UIKit

class PeriodSelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
