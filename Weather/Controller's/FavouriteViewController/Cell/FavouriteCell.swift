//
//  FavouriteCell.swift
//  Weather
//
//  Created by Stanislav on 30.10.2020.
//

import UIKit

class FavouriteCell: UITableViewCell {
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var favouriteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favouriteView.layer.cornerRadius = 0
        favouriteView.addBottomShadow()
    }
}
