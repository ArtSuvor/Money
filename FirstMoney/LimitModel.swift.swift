//
//  LimitModel.swift.swift
//  FirstMoney
//
//  Created by Art on 25.09.2021.
//

import RealmSwift
import Foundation

class LimitModel: Object {
    @objc dynamic var limitSum = ""
    @objc dynamic var limitDate = NSDate()
    @objc dynamic var limitLastDay = NSDate()
}
