//
//  IntExtension.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/02/02.
//
//
import Foundation

extension Int {
    var commaSeparated: String {
        let formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.decimalSeparator = ","
        formatter.groupingSize = 3
        return formatter.stringFromNumber(self)!
    }
}