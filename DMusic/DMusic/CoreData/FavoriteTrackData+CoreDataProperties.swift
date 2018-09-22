//
//  FavoriteTrackData+CoreDataProperties.swift
//  
//
//  Created by Ledung95d on 9/22/18.
//
//

import Foundation
import CoreData


extension FavoriteTrackData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteTrackData> {
        return NSFetchRequest<FavoriteTrackData>(entityName: "FavoriteTrackData")
    }

    @NSManaged public var artwork_url: String?
    @NSManaged public var duration: Int64
    @NSManaged public var genre: String?
    @NSManaged public var id: Int64
    @NSManaged public var title: String?

}
