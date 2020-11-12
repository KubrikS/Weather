//
//  CurrentTempCell.swift
//  Weather
//
//  Created by Stanislav on 30.10.2020.
//

import UIKit
import CoreData

class CurrentTempCell: UITableViewCell {
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var desriptionLabel: UILabel!
    @IBOutlet weak var feelsLabel: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var mainView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundForCurrentCell")!)
        mainView.addBottomShadow()
    }
}
