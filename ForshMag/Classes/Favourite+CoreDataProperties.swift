//
//  Favourite+CoreDataProperties.swift
//  ForshMag
//
//  Created by  Tim on 16.04.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import CoreData


extension Favourite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourite> {
        return NSFetchRequest<Favourite>(entityName: "Favourite")
    }

    @NSManaged public var id: Int16
    @NSManaged public var isFavourite: Bool

}
