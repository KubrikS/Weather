//
//  MainViewController+Delegate.swift
//  Weather
//
//  Created by Stanislav on 24.11.2020.
//

import UIKit

protocol FavouriteDelegate: AnyObject {
    func mainWeatherUpdate(for city: String)
}
