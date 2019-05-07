//
//  YearlyViewController.swift
//  NRICH
//
//  Created by neulioncollege on 2/1/19.
//  Copyright © 2019 gergusa04. All rights reserved.
//

import UIKit
import FirebaseDatabase

class YearlyViewController: UIViewController {
    
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var allExpenses = [Expense]()
    var yearlyExpenses = [Expense]()
    
    let indexer = GlobalId.shared
    var availableMoney: Double = 0.00 {
        didSet {
            updateLabel()
        }
    }
    
    @IBOutlet weak var summarytableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirebaseData()
    }
    
    func setupFirebaseData() {
        ref = Database.database().reference()
        handle = ref?.child("Expense").observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value as? [String: String] {
                let anExspense = Expense()
                if let desc = item["Descript"] {
                    anExspense.descript = desc
                }
                if let amt = item["Amount"] {
                    anExspense.amount = amt
                }
                if let id = item["Id"] {
                    anExspense.id = id
                }
                if let date = item["Date"] {
                    anExspense.date = date
                }
                
                self.yearlyExpenses.insert(anExspense, at: 0)
                
                if let amount = item["Amount"]  {
                    if let itemAmount = Double(amount) {
                        self.availableMoney += itemAmount
                    }
                }
                self.sortExpensesByDateAndMonth()
                self.summarytableView.reloadData()
            }
        })
        
        handle = ref?.child("Expense").observe(.childRemoved, with: { (snapshot) in
            if let item = snapshot.value as? [String: String] {
                if let id = item["Id"] {
                    
                    for (i, e) in self.yearlyExpenses.enumerated() {
                        if e.id == id {
                            self.yearlyExpenses.remove(at: i)
                            break
                        }
                    }
                    self.sortExpensesByDateAndMonth()
                    self.summarytableView.reloadData()
                    self.resetBalance()
                    for someAmount in self.yearlyExpenses {
                        self.calculateBalance(from: someAmount)
                    }
                }
            }
        })
        
        handle = ref?.child("Expense").observe(.childChanged, with: { (snapshot) in
            if let item = snapshot.value as? [String: String] {
                if let id = item["Id"] {
                    
                    for (i, e) in self.yearlyExpenses.enumerated() {
                        if e.id == id {
                            let anExspense = Expense()
                            if let desc = item["Descript"] {
                                anExspense.descript = desc
                            }
                            if let amt = item["Amount"] {
                                anExspense.amount = amt
                            }
                            if let id = item["Id"] {
                                anExspense.id = id
                            }
                            if let date = item["Date"] {
                                anExspense.date = date
                            }
                            self.yearlyExpenses.remove(at: i)
                            self.yearlyExpenses.insert(anExspense, at: i)
                        }
                    }
                    self.sortExpensesByDateAndMonth()
                    self.summarytableView.reloadData()
                    self.resetBalance()
                    for someAmount in self.yearlyExpenses {
                        self.calculateBalance(from: someAmount)
                    }
                }
            }
        })
    }
    
    func sortExpensesByDateAndMonth() {
        let sortedExpenses = yearlyExpenses.sorted(by: { $0.date > $1.date } )
        yearlyExpenses.removeAll()
        yearlyExpenses = sortedExpenses
    }
    
    func resetBalance() {
        availableMoney = 0.00
    }
    
    func calculateBalance(from expense: Expense) {
        let amount = expense.amount
        if let itemAmount = Double(amount) {
            self.availableMoney += itemAmount
        }
    }
    
    func updateLabel() {
        balanceLabel.text = String(format: "$%.2f", availableMoney)
    }
    
}

extension YearlyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yearlyExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ExpenseYearlyCell")
        let item = yearlyExpenses[indexPath.row]
        cell.textLabel?.numberOfLines = 3
        var dateString = ""
        if let date = Formatter.apiDateFormat.date(from: item.date) {
            dateString = Formatter.readableDateFormat.string(from: date)
        }
        
        cell.textLabel?.text = item.descript
        cell.detailTextLabel?.text = "\(item.amount)       \(dateString)"
        
        
        return cell
    }
    
}

extension YearlyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

    


