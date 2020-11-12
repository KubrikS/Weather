//
//  ConditionCell.swift
//  Weather
//
//  Created by Stanislav on 30.10.2020.
//

import UIKit

class ConditionCell: UITableViewCell {
    @IBOutlet var sunriseLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet var sunsetLabel: UILabel!
    @IBOutlet var conditionView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        conditionView.layer.cornerRadius = 10
        conditionView.addBottomShadow()
    }
}
