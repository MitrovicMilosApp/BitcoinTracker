//
//  BuySellVC.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/25/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit

class BuySellVC: UIViewController {
    
    
    // MARK: - Enums
    
    enum BuyOrSell {
        case buy
        case sell
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchPicker()
        configureTapGesture()
    }
    
    
    // MARK: - Vars & Lets
    
    var model = Model()
    var picker = BuyOrSell.buy
    var priceForBitcoin = Double()
    var numberOfBitcoins = Double()
    var isValidEntry = true

    
    // MARK: - Outlets
    
    @IBOutlet weak var buySellLabel: UILabel!
    @IBOutlet weak var numberOfBitcoinsTextField: UITextField!
    @IBOutlet weak var pricePerBitcoinTextField: UITextField!
    
    
    // MARK: - Methods

    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BuySellVC.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    func switchPicker() {
        switch picker {
        case .buy:
            buySellLabel.text = "Buy"
        case .sell:
            buySellLabel.text = "Sell"
        }
    }

    func createEntry() {
        guard let price = Double(pricePerBitcoinTextField.text!) else {
            createAlert()
            return
        }
        guard let bitcoins = Double(numberOfBitcoinsTextField.text!) else {
            createAlert()
            return
        }
        priceForBitcoin = price
        numberOfBitcoins = bitcoins
    }
    
    func notEnoughBitcoinsAlert() {
        let title = "Not enough Bitcoins to sell!"
        let message = "You have \(model.totalNumberOfBitcoins) Bitcoins to sell"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.performSegue(withIdentifier: "UnwindSegue", sender: self)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
 
    func confirm() {
        createEntry()
        if isValidEntry {
            switch picker {
            case .buy:
                if numberOfBitcoins > 0 {
                model.buy(price: priceForBitcoin, bitcoins: numberOfBitcoins)
                model.coreDataAddEntry()
                print("-----model.buy -- cena: \(priceForBitcoin), broj: \(numberOfBitcoins)")
                performSegue(withIdentifier: "UnwindSegue", sender: self)
                } else {
                    createAlert()
                }
            case .sell:
                if model.totalNumberOfBitcoins >= numberOfBitcoins {
                    model.sell(price: priceForBitcoin, bitcoins: numberOfBitcoins)
                    model.coreDataAddEntry()
                    performSegue(withIdentifier: "UnwindSegue", sender: self)
                } else {
                    notEnoughBitcoinsAlert()
                }
            }
        }
    }
    
    func createAlert() {
        let title = "Incorrect format"
        let message = "Please insert correct format, ex 5600.00"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.performSegue(withIdentifier: "UnwindSegue", sender: self)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
        isValidEntry = false
    }
    
    
    // MARK: - Actions
    
    @IBAction func confirmButton(_ sender: BorderButton) {
        confirm()
        print("confirmed")
    }
    
    @IBAction func cancelButton(_ sender: BorderButton) {
        dismiss(animated: true)
    }
}

