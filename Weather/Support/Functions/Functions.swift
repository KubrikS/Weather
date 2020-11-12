//
//  Functions.swift
//  Weather
//
//  Created by Stanislav on 30.10.2020.
//

import UIKit

enum typeUnixConvertor {
    case time
    case timeWithTimezone
    case date
    case weekDay
}

func unixConvertor(unixTime: Double, timezone: Int = 0, type: typeUnixConvertor) -> String {
    let time = NSDate(timeIntervalSince1970: unixTime)
    let dateFormatter = DateFormatter()
    
    switch type {
    case .date:
        dateFormatter.dateFormat = "MMM d"
        let dateAsString = dateFormatter.string(from: time as Date)
        dateFormatter.dateFormat = "MMM d"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "MMM d"
        let date24 = dateFormatter.string(from: date!)
        
        return date24
    case .time:
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.system.identifier) as Locale?
        dateFormatter.dateFormat = "hh:mm a"
        let dateAsString = dateFormatter.string(from: time as Date)
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        
        return date24
    case .timeWithTimezone:
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.system.identifier) as Locale?
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezone)
        dateFormatter.dateFormat = "hh:mm a"
        let dateAsString = dateFormatter.string(from: time as Date)
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        
        return date24
    case .weekDay:
        dateFormatter.dateFormat = "EEEE"
        let dateAsString = dateFormatter.string(from: time as Date)
        dateFormatter.dateFormat = "EEEE"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "EEEE"
        let date24 = dateFormatter.string(from: date!)
        
        return date24
    }
}

func convertToMercury(_ param: Double) -> Int {
    let result = param / 133 * 100
    return Int(result)
}

func setIcon(condition: String) -> UIImage {
    var image = UIImage()
    let rareCondition = ["Mist", "Smoke", "Haze", "Dust", "Fog", "Sand", "Ash", "Squall", "Tornado"]
    
    if condition == "Clear" {
        image = UIImage(named: "sun")!
    } else if condition == "Clouds" {
        image = UIImage(named: "clouds")!
    } else if condition == "Snow" {
        image = UIImage(named: "snow")!
    } else if condition == "Rain" {
        image = UIImage(named: "rain")!
    } else if condition == "Drizzle" {
        image = UIImage(named: "rain")!
    } else if condition == "Thunderstorm" {
        image = UIImage(named: "storm")!
    } else if rareCondition.contains(condition) {
        image = UIImage(named: "haze")!
    }
    
    return image
}
