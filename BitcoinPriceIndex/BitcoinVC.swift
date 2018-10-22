//
//  BitcoinVC.swift
//  BitcoinPriceIndex
//
//  Created by Milos Mitrovic on 7/12/18.
//  Copyright © 2018 Milos Mitrovic. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class BitcoinVC: UIViewController {
    
    
    // MARK: - Enums
    
    enum Selector {
        case USD
        case GBP
        case EUR
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uzima podatke iz Core Data
        model.coreDataRefresher() // -------------- 19.09
        timerStart()
        setupLayout()
        getData(url: bitcoinURL)
        referencePriceTextField.delegate = self
        
    }
    
    
    // MARK: - Vars & Lets

    var model = Model()
    var currencySelector: Selector = .EUR           // selector for BitcoinVC
    var bitcoinURL = "https://api.coindesk.com/v1/bpi/currentprice.json"
    var arrayOfCurrencies = ["USD", "GBP", "EUR"]
    var arrayOfPricesStringValue = [String]()
    var referencePrice = Double()
    var dropMenuButtonSelected = false
    var chartButtonSelected = false
    var switchView = true
    
    // prices for graph
    var pricesOverTimeUSD = [Double]()
    var pricesOverTimeGBP = [Double]()
    var pricesOverTimeEUR = [Double]()
    
    // prepareForSegue
    var selectedCurrencyForCalculateVC: Selector = .EUR         // selector for CalculateVC
    var currencyForCalculateVCSelected = false

    
    // MARK: - Outlets
    
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var bitcoinImage: UIImageView!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var dropButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var referencePriceTextField: UITextField!
    @IBOutlet weak var calculateButtonOutlet: UIButton!
    
    
    // MARK: - Methods
    
    func selectTradingCurrencyAlert() {
        let title = ""
        let message = "Please select your trading currency in order to continue to the next page."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let actionUSD = UIAlertAction(title: "USD", style: .default) { _ in
            self.selectedCurrencyForCalculateVC = .USD
            self.currencyForCalculateVCSelected = true
            self.performSegue(withIdentifier: "Segue", sender: self)
        }
        let actionEUR = UIAlertAction(title: "EUR", style: .default) { (_) in
            self.selectedCurrencyForCalculateVC = .EUR
            self.currencyForCalculateVCSelected = true
            self.performSegue(withIdentifier: "Segue", sender: self)
        }
        let actionGBP = UIAlertAction(title: "GBP", style: .default) { (_) in
            self.selectedCurrencyForCalculateVC = .GBP
            self.currencyForCalculateVCSelected = true
            self.performSegue(withIdentifier: "Segue", sender: self)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionEUR)
        alert.addAction(actionGBP)
        alert.addAction(actionUSD)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertNoInternetAccess() {
        let message = "There is no access to the internet, please check connection."
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func alertIncorrectFormat() {
        
        let message = "Please insert correct format \n ex: 5600.00"
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func getData(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            let decoder = JSONDecoder()
            if let result = try? decoder.decode(PricingModel.self, from: response.data!) {
                let priceUSD = result.bpi.USD.rate_float
                let priceGBP = result.bpi.GBP.rate_float
                let priceEUR = result.bpi.EUR.rate_float
                
                if priceGBP != self.pricesOverTimeGBP.last {
                    self.pricesOverTimeUSD.append(priceUSD)
                    self.pricesOverTimeGBP.append(priceGBP)
                    self.pricesOverTimeEUR.append(priceEUR)
                    
                    self.arrayOfPricesStringValue = [String]()
                    self.arrayOfPricesStringValue.append(String(priceUSD))
                    self.arrayOfPricesStringValue.append(String(priceGBP))
                    self.arrayOfPricesStringValue.append(String(priceEUR))
                }
                switch self.selectedCurrencyForCalculateVC {
                case .EUR:
                    self.model.currentBitcoinPrice = priceEUR
                case .USD:
                    self.model.currentBitcoinPrice = priceUSD
                case .GBP:
                    self.model.currentBitcoinPrice = priceGBP
                }
            }
        }
    }
    
    func timerStart() {
        _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(chartRefresher), userInfo: nil, repeats: true)
    }
    
    @objc func chartRefresher() {
        var pricesArray = [Double]()
        switch currencySelector {
        case .USD:
            pricesArray = pricesOverTimeUSD
            bitcoinPriceLabel.text = "USD \(pricesArray.last ?? 0) "
        case .GBP:
            pricesArray = pricesOverTimeGBP
            bitcoinPriceLabel.text = "GBP \(pricesArray.last ?? 0) "
        case .EUR:
            pricesArray = pricesOverTimeEUR
            bitcoinPriceLabel.text = "EUR \(pricesArray.last ?? 0) "
        }
        chartViewRefresher(pricesArray: pricesArray)
        getData(url: bitcoinURL)
    }
    
    func referencePriceEntry() {
        if let price = Double(referencePriceTextField.text!) {
            referencePrice = price
            print(referencePrice)
        } else {
            alertIncorrectFormat()
        }
    }
    
    func chartViewRefresher(pricesArray: [Double]) {
        var counter = -1.0
        var lineChartEntry = [ChartDataEntry()]
        var lineChartEntryReference = [ChartDataEntry()]
        var barChartEntry = [BarChartDataEntry()]
    
        if pricesArray.isEmpty == false {
            for price in pricesArray {
                counter += 1
                let constantPrice = referencePrice
                
                // lineChart
                let value = ChartDataEntry(x: counter, y: price - constantPrice)
                lineChartEntry.append(value)
                
                let valueForReference = ChartDataEntry(x: counter, y: 0)
                lineChartEntryReference.append(valueForReference)

                // barChart
                let valueForBar = BarChartDataEntry(x: counter, y: price - constantPrice)
                barChartEntry.append(valueForBar)
            }
        }
        
        // lineChart
        // lineChart - first line
        let lines = LineChartDataSet(values: lineChartEntry, label: "Bitcoin")
        lines.colors = [NSUIColor.blue]
        lines.circleColors = [NSUIColor.blue]
        lines.circleRadius = 2
        lines.circleHoleRadius = 1
        lines.lineWidth = 1.5
        let linesData = LineChartData()
        linesData.addDataSet(lines)
        
        // lineChart - second line
        let referenceLine = LineChartDataSet(values: lineChartEntryReference, label: "Reference")
        referenceLine.colors = [NSUIColor.red]
        referenceLine.lineWidth = 1.5
        referenceLine.circleRadius = 0
        referenceLine.circleHoleRadius = 0
        linesData.addDataSet(referenceLine)
        lineChartView.data = linesData
        
        // barChart
        let bars = BarChartDataSet(values: barChartEntry, label: "Bitcoin")
        let barsData = BarChartData()
        barsData.addDataSet(bars)
        barChartView.data = barsData
    }
    
    func setupLayout() {
        tableView.isHidden = true
        tableView.backgroundColor = UIColor.clear
        
        bitcoinPriceLabel.layer.cornerRadius = bitcoinPriceLabel.frame.height / 2
        bitcoinPriceLabel.layer.borderWidth = 2
        bitcoinPriceLabel.layer.borderColor = UIColor.borderColor.cgColor
        bitcoinPriceLabel.clipsToBounds = true
        
        bitcoinImage.layer.cornerRadius = bitcoinImage.frame.height / 2
        
        chartButton.layer.cornerRadius = chartButton.frame.height / 2
        chartButton.layer.borderColor = UIColor.borderColor.cgColor
        chartButton.layer.borderWidth = 2
        chartButton.clipsToBounds = true
    }
    
    func switchChartButtonLayout() {
        if chartButtonSelected == true {
            chartButtonSelected = false
            chartButton.setTitle("Switch to Line Chart View", for: .normal)
        } else {
            chartButtonSelected = true
            chartButton.setTitle("Switch to Bar Chart View", for: .normal)
        }
    }
    
    func dropMenuButtonTapped() {
        if dropMenuButtonSelected == false {
            dropMenuButtonSelected = true
            tableView.isHidden = false
        } else {
            dropMenuButtonSelected = false
            tableView.isHidden = true
        }
    }

    
    // MARK: - Actions
    
    @IBAction func dropMenuAction(_ sender: UIButton) {
        dropMenuButtonTapped()
    }
    
    @IBAction func calculateVCButton(_ sender: BorderButton) {
        if currencyForCalculateVCSelected == false {
            selectTradingCurrencyAlert()
        } else {
            performSegue(withIdentifier: "Segue", sender: self)
        }
    }
    
    @IBAction func chartAction(_ sender: UIButton) {
        switchChartButtonLayout()
        chartRefresher()
        if switchView == true {
            barChartView.isHidden = true
            lineChartView.isHidden = false
            switchView = false
        } else {
            barChartView.isHidden = false
            lineChartView.isHidden = true
            switchView = true
        }
    }
    
    
    // MARK: - Navigation
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            let destination = segue.destination as? CalculateVC
            destination?.model = self.model
            destination?.currencySelector = self.selectedCurrencyForCalculateVC
        }
    }
}

// MARK: - Extensions

// MARK: - Extensions - UITableViewDataSource

extension BitcoinVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CurrencyTVCell
        cell.populateCell(text: arrayOfCurrencies[indexPath.row])
        return cell
    }
}

// MARK: - Extensions - UITableViewDelegate

extension BitcoinVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getData(url: bitcoinURL)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CurrencyTVCell
        cell.modelVC = self
        cell.updateCells(indexPath: indexPath)
        print(currencySelector)

        dropMenuButtonTapped()
    }
}

// MARK: - Extensions - UITextFieldDelegate

extension BitcoinVC: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        referencePriceEntry()
        chartRefresher()
    }
}






