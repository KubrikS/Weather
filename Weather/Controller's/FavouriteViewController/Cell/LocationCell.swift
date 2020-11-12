//
//  LocationCell.swift
//  Weather
//
//  Created by Stanislav on 02.11.2020.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var locationView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        locationView.layer.cornerRadius = 0
        locationView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundForCurrentCell")!)
        locationView.addBottomShadow()
    }
    
}
