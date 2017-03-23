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
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: self as NSNumber)!
    }
}
