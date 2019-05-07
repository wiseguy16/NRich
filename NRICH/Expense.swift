//
//  Expense.swift
//  NRICH
//
//  Created by Gregory Weiss on 12/31/18.
//  Copyright © 2018 gergusa04. All rights reserved.
//

import Foundation

class Expense {
    
    var descript = ""
    var amount = ""
    var id = ""
    var date = "" {
        didSet {
            if let date = Formatter.apiDateFormat.date(from: date) {
                monthOfExpense = date.month
            }
        }
    }
    var monthOfExpense = ""
    
}
