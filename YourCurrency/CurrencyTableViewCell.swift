//
//  CurrencyTableViewCell.swift
//  YourCurrency
//
//  Created by Екатерина Полупанова on 15.06.2021.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    
    var item:RSSItem! {
        didSet {
            titleLabel.text  = item.value
            dateLabel.text = item.date
        }
    }

}
