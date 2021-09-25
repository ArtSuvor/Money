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
    
    @IBOutlet var limitLabel: UILabel!
    @IBOutlet var howManyCanSpend: UILabel!
    @IBOutlet var spendByCheck: UILabel!
    
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
        }
        let alertCancel = UIAlertAction(title: "Отмена", style: .cancel)

        
        alertController.addTextField { money in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        alertController.addTextField { day in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        present(alertController, animated: true, completion: nil)
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
              let spending = spendingArray else { return UITableViewCell() }
        cell.configure(with: spending[indexPath.row])
        return cell
    }
    
    //удаление ячейки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let spending = spendingArray?[indexPath.row] else { return }
            try! realm.write {
                realm.delete(spending)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default: return
        }
    }
}
