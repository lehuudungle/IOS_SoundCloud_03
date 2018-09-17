//
//  DownloadTrackData+CoreDataProperties.swift
//  
//
//  Created by Ledung95d on 9/17/18.
//
//

import Foundation
import CoreData


extension DownloadTrackData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadTrackData> {
        return NSFetchRequest<DownloadTrackData>(entityName: "DownloadTrackData")
    }

    @NSManaged public var artwork_url: String?
    @NSManaged public var duration: Int64
    @NSManaged public var id: Int64
    @NSManaged public var url_local: String?
    @NSManaged public var genre: String?
    @NSManaged public var title: String?

}
