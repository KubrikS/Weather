//
//  CurrentWeatherModel.swift
//  Weather
//
//  Created by Stanislav on 05.11.2020.
//

import Foundation

struct CurrentWeatherModel: Decodable {
    let name: String
    let dt: Double
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let coord: Coord
    let sys: Sys
    let timezone: Int
    let cod: Int
}

struct Main: Decodable {
    var humidity: Double
    var pressure: Double
    var temp: Double
    var feelsLike: Double
    
    enum CodingKeys: String, CodingKey {
        case humidity
        case pressure
        case temp
        case feelsLike = "feels_like"
    }
}

struct Weather: Decodable {
    let main: String
    let description: String
    let icon: String
}

struct Wind: Decodable {
    let speed: Double
}

struct Coord: Decodable {
    let lat: Double
    let lon: Double
}

struct Sys: Decodable {
    let sunrise: Double
    let sunset: Double
}

