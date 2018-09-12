//
//  Track.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import ObjectMapper
import UIKit

class TracksResponse: Mappable {
    var collection = [InfoTrack]()
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        collection <- map["collection"]
    }
}

class SearchResultTracks: Mappable {
    var collection = [Track]()
    var total_results: CUnsignedLong!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        collection <- map["collection"]
        total_results <- map["total_results"]
    }
}

class InfoTrack: Mappable {
    var track: Track!
    var score = 0
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        track <- map["track"]
        score <- map["score"]
    }
}

class Track: Mappable {
    var artwork_url = ""
    var duration:CUnsignedLong = 0
    var genre = "No Generic"
    var id: Int64 = 0
    var title = "No Name"
    var streamURL = ""
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        artwork_url <- map["artwork_url"]
        duration <- map["duration"]
        genre <- map["genre"]
        id <- map["id"]
        title <- map["title"]
        streamURL <- map["streamURL"]
    }
}
