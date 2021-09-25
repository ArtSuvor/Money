//
//  CustomTableViewCell.swift
//  FirstMoney
//
//  Created by Art on 24.09.2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

//MARK: - Outlets
    
    @IBOutlet private var recordImageView: UIImageView!
    @IBOutlet private var recordCategoryLabel: UILabel!
    @IBOutlet private var recordCostLabel: UILabel!
        
//MARK: - Properties images
    
    private let imageFood = UIImage(named: "icons8-мертвая-еда-48")
    private let imageClothes = UIImage(named: "icons8-женский-костюм-48")
    private let imageCellular = UIImage(named: "icons8-громкая-связь-48")
    private let imageRelax = UIImage(named: "icons8-relax-48")
    private let imageBeauty = UIImage(named: "icons8-стрижка-48")
    private let imageAuto = UIImage(named: "icons8-автоматическая-автомойка-48")

//MARK: - Func config
    
    func configure(with spending: SpendingModel) {
        self.recordCategoryLabel.text = spending.categoty
        self.recordCostLabel.text = "\(spending.cost)"
        
        switch spending.categoty {
        case "Еда": self.recordImageView.image = imageFood
        case "Одежда": self.recordImageView.image = imageClothes
        case "Связь": self.recordImageView.image = imageCellular
        case "Досуг": self.recordImageView.image = imageRelax
        case "Красота": self.recordImageView.image = imageBeauty
        case "Авто": self.recordImageView.image = imageAuto
        default: self.recordImageView.image = UIImage(systemName: "list.triangle")
        }
    }
}
