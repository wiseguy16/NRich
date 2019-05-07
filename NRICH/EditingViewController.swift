//
//  EditingViewController.swift
//  NRICH
//
//  Created by Gregory Weiss on 12/31/18.
//  Copyright © 2018 gergusa04. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditingViewController: UIViewController {

    @IBOutlet weak var descriptTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    var expense: Expense!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptTextField.text = expense.descript
        amountTextField.text = expense.amount
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        if descriptTextField.text != nil && descriptTextField.text != "" && amountTextField.text != nil && amountTextField.text != "" {
            let desc = descriptTextField.text ?? "misc"
            let amt = amountTextField.text ?? "00.00"
            updateExspense(id: expense.id, descript: desc, amount: amt)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateExspense(id: String, descript: String, amount: String) {
        let ref = Database.database().reference().child("Expense/\(id)")
        let newExpense: [String: String] = ["Descript": descript, "Amount": amount, "Id": id , "Date": expense.date]
        ref.updateChildValues(newExpense)
    }
    
    func removeExpense(id: String) {
        let ref = Database.database().reference().child("Expense/\(id)")
        ref.removeValue()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        removeExpense(id: expense.id)
    }
    
    @IBAction func cancelEditTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
