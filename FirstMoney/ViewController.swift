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
