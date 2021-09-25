//
//  ViewController.swift
//  FirstMoney
//
//  Created by Art on 23.09.2021.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

//MARK: - Outlets
    
    @IBOutlet private var limitLabel: UILabel!
    @IBOutlet private var howManyCanSpend: UILabel!
    @IBOutlet private var spendByCheck: UILabel!
    @IBOutlet private var allSpending: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var displayLabel: UILabel!
    @IBOutlet private var numberFromKeyboard: [UIButton]! {
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    
//MARK: - Properties
    
    private let cellID = "TableViewCell"
    private var stillTyping = false
    private var categoryName = ""
    private var displayValue: Int = 1
    private let realm = try! Realm()
    private var spendingArray: Results<SpendingModel>?
    
//MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spendingArray = realm.objects(SpendingModel.self)
        leftLabels()
        allSpend()
    }
    
//MARK: - Actions buttons
    
    //кнопки клавиатуры
    @IBAction private func numberPressed(_ sender: UIButton) {
        guard let number = sender.currentTitle,
              let displayText = displayLabel.text else { return }
        
        if number == "0" && displayText == "0" {
            stillTyping = false
        } else {
            if stillTyping {
                if displayText.count < 15 {
                    displayLabel.text = displayText + number
                }
            } else {
                displayLabel.text = number
                stillTyping = true
            }
        }
    }
    
    //кнопка очистки
    @IBAction private func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    //кнопки категорий
    @IBAction private func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!)!
        
        displayLabel.text = "0"
        stillTyping = false
        
        let value = SpendingModel(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
        }
        leftLabels()
        allSpend()
        tableView.reloadData()
    }
    
    //установка лимита и запись в бд
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in
            
            guard let textFieldSum = alertController.textFields?[0].text,
            let textFieldDay = alertController.textFields?[1].text else { return }
            
            self.limitLabel.text = textFieldSum
            let day = textFieldDay
            let dateNow = Date()
            let lastDay = dateNow.addingTimeInterval(60*60*24*(Double(day) ?? 0))
            
            let limit = self.realm.objects(LimitModel.self)
            if limit.isEmpty {
                let value = LimitModel(value: [textFieldSum, dateNow, lastDay])
                try! self.realm.write {
                    self.realm.add(value)
                }
            } else {
                try! self.realm.write {
                    limit[0].limitSum = textFieldSum
                    limit[0].limitDate = dateNow as NSDate
                    limit[0].limitLastDay = lastDay as NSDate
                }
            }
            self.leftLabels()
        }

        alertController.addTextField { money in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        alertController.addTextField { day in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func leftLabels() {
        let limit = realm.objects(LimitModel.self)
        guard !limit.isEmpty else {return}
        limitLabel.text = limit[0].limitSum
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        guard let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00"),
              let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") else { return }
        let filteredLimit: Int = realm.objects(SpendingModel.self).filter("date >= %@ && date <= %@", startDate, endDate).sum(ofProperty: "cost")
        spendByCheck.text = "\(filteredLimit)"
        
        guard let limitString = limitLabel.text,
        let limitInt = Int(limitString),
        let spendString = spendByCheck.text,
        let spendInt = Int(spendString) else { return }
        let moneyAfterSpending = limitInt - spendInt
        howManyCanSpend.text = "\(moneyAfterSpending)"
    }
    
    private func allSpend() {
        let allSpend: Int = realm.objects(SpendingModel.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)"
    }
}

//MARK: - Extension tableView

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //количество ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        spendingArray?.count ?? 0
    }
    
    //конфиг ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CustomTableViewCell,
              let spending = spendingArray?.sorted(byKeyPath: "date", ascending: false) else { return UITableViewCell() }
        cell.configure(with: spending[indexPath.row])
        return cell
    }
    
    //удаление ячейки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let spending = spendingArray?.sorted(byKeyPath: "date", ascending: false) else { return }
            try! realm.write {
                realm.delete(spending[indexPath.row])
            }
            leftLabels()
            allSpend()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default: return
        }
    }
}
