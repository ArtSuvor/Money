//
//  SpendingModel.swift
//  FirstMoney
//
//  Created by Art on 25.09.2021.
//

import RealmSwift
import Foundation

class SpendingModel: Object {
    @objc dynamic var categoty = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
}
