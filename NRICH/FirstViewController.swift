//
//  ViewController.swift
//  NRICH
//
//  Created by Gregory Weiss on 12/30/18.
//  Copyright © 2018 gergusa04. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FirstViewController: UIViewController {

    @IBOutlet weak var myTextfield: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    
    var ref: DatabaseReference?
    let indexer = GlobalId.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        myTextfield.text = ""
        numberTextField.text = ""
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        ref = Database.database().reference()

        if myTextfield.text != nil && myTextfield.text != "" && numberTextField.text != nil && numberTextField.text != "" {
            let number = Int.random(in: 0 ... 999999)
            let id = "\(number)"
            let expense: [String: String] = ["Descript": myTextfield.text ?? "misc", "Amount": numberTextField.text ?? "00.00", "Id": id, "Date": "\(Date())"]
            
            ref?.child("Expense").child(id).setValue(expense)
            myTextfield.text = ""
            numberTextField.text = ""
            self.dismiss(animated: true, completion: nil)

        }
    }
    
}

