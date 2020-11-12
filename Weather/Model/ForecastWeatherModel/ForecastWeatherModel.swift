//
//  ForecastWeatherModel.swift
//  Weather
//
//  Created by Stanislav on 05.11.2020.
//

import Foundation

struct ForecastModel: Decodable {
    var list: [List]
}

struct List: Decodable {
    let dt: Int
    let main: WeatherTemperature
    let weather: [WeatherCondition]
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather
        case dtTxt = "dt_txt"
    }
}

struct WeatherTemperature: Decodable {
    let temp: Double
}

struct WeatherCondition: Decodable {
    let main, weatherDescription: String

    enum CodingKeys: String, CodingKey {
        case main
        case weatherDescription = "description"
    }
}
