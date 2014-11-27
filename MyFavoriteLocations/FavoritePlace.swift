//
//  FavoritePlace.swift
//  MyFavoriteLocations
//
//  Created by Steven De Cock on 5/11/14.
//  Copyright (c) 2014 Steven De Cock. All rights reserved.
//

import Foundation
import CoreData

class FavoritePlace: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var placeName: String
    @NSManaged var foto: NSData
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var comment: String
    

}
