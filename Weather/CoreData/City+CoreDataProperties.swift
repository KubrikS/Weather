//
//  City+CoreDataProperties.swift
//  Weather
//
//  Created by Stanislav on 01.11.2020.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var name: String?
    @NSManaged public var descrip: String?
    @NSManaged public var temp: Double

}

extension City : Identifiable {

}
