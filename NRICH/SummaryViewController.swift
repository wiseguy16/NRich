//
//  SummaryViewController.swift
//  NRICH
//
//  Created by Gregory Weiss on 12/30/18.
//  Copyright © 2018 gergusa04. All rights reserved.
//

import UIKit
import FirebaseDatabase


class SummaryViewController: UIViewController {
    
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var allExpenses = [Expense]()
    var monthlyExpenses = [Expense]()
    
    let indexer = GlobalId.shared
    var availableMoney: Double = 2000.00 {
        didSet {
            updateLabel()
        }
    }
    var currentMonth = ""
    
    @IBOutlet weak var summarytableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentMonth = Date().month
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
                if anExspense.monthOfExpense == self.currentMonth {
                    
                    self.monthlyExpenses.insert(anExspense, at: 0)
                    
                    if let amount = item["Amount"]  {
                        if let itemAmount = Double(amount) {
                            self.availableMoney -= itemAmount
                            print("\(self.availableMoney)")
                        }
                    }
                }
                self.sortExpensesByDateAndMonth()
                self.summarytableView.reloadData()
            }
        })
        
        handle = ref?.child("Expense").observe(.childRemoved, with: { (snapshot) in
            if let item = snapshot.value as? [String: String] { print("Dictionary >> :\(item)")
                if let id = item["Id"] {
                    
                    for (i, e) in self.monthlyExpenses.enumerated() {
                        if e.id == id {
                            print("\(e.id)")
                            self.monthlyExpenses.remove(at: i)
                            break
                        }
                    }
                    self.sortExpensesByDateAndMonth()
                    self.summarytableView.reloadData()
                    self.resetBalance()
                    for someAmount in self.monthlyExpenses {
                        self.calculateBalance(from: someAmount)
                    }
                }
            }
        })
        
        handle = ref?.child("Expense").observe(.childChanged, with: { (snapshot) in
            if let item = snapshot.value as? [String: String] { print("Dictionary >> :\(item)")
                if let id = item["Id"] {
                    
                    for (i, e) in self.monthlyExpenses.enumerated() {
                        if e.id == id {
                            print("\(e.id)")
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
                            if anExspense.monthOfExpense == self.currentMonth {
                                self.monthlyExpenses.remove(at: i)
                                self.monthlyExpenses.insert(anExspense, at: i)
                            }
                        }
                    }
                    self.sortExpensesByDateAndMonth()
                    self.summarytableView.reloadData()
                    self.resetBalance()
                    for someAmount in self.monthlyExpenses {
                        self.calculateBalance(from: someAmount)
                    }
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentMonth = Date().month
    }
    
    func sortExpensesByDateAndMonth() {
        let filteredByMonthExpenses = monthlyExpenses.filter({ $0.monthOfExpense == currentMonth })
        let sortedExpenses = filteredByMonthExpenses.sorted(by: { $0.date > $1.date } )
        monthlyExpenses.removeAll()
        monthlyExpenses = sortedExpenses
    }
    
    func resetBalance() {
        availableMoney = 2000.00
    }
    
    func calculateBalance(from expense: Expense) {
        let amount = expense.amount
        if let itemAmount = Double(amount) {
            self.availableMoney -= itemAmount
            print("\(self.availableMoney)")
        }
    }
    
    func updateLabel() {
        balanceLabel.text = String(format: "$%.2f", availableMoney)
    }
    
}

extension SummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlyExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ExpenseCell")
        let item = monthlyExpenses[indexPath.row]
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

extension SummaryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = monthlyExpenses[indexPath.row]
        guard let destVC = storyboard?.instantiateViewController(withIdentifier: "EditingViewController") as? EditingViewController else { return }
        destVC.expense = item
        navigationController?.pushViewController(destVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
