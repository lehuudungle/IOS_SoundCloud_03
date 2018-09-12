//
//  URLs.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
struct URLs {
    private static let APIBaseUrl = "https://api-v2.soundcloud.com"
    private static let APIBaseStreamURL = "https://api.soundcloud.com/tracks"
    private static let ComponentUrl = "/charts?kind=top&genre=soundcloud%3Agenres%3"
    private static let APIDownloadURL = "http://api.soundcloud.com/tracks"
    public static let APISearchUrl = String(format: "%@%@&client_id=%@", APIBaseUrl, LinkURL.searchURL.rawValue, APIKey.CliendId)
    
    static func getLinkGeneric(_ linkURL: LinkURL) ->String {
        return String(format: "%@%@%@&client_id=%@", APIBaseUrl, ComponentUrl, linkURL.getURL(), APIKey.CliendId)
    }
    static func getStreamURL(id: Int64) -> String {
        return String(format: "%@/%@/stream?client_id=%@", APIBaseStreamURL,"\(id)", APIKey.CliendId)
    }
    static func getDownloadURL(id: Int64) -> String {
        return String(format: "%@/%@/download?client_id=%@", APIDownloadURL,"\(id)", APIKey.CliendId)
    }
}

public enum LinkURL: Int {
    case allMusicURL, allAudioURL,
    alternativerockURL, ambientURL,
    classicalURL, countryURL, searchURL, streamURL
    
    var titleGeneric: String {
        switch  self {
        case .allMusicURL:
            return "All Music"
        case .allAudioURL:
            return "All Audio"
        case .alternativerockURL:
            return "Alternativerock"
        case .ambientURL:
            return "Ambient"
        case .classicalURL:
            return "Classical"
        case .countryURL:
            return "Country"
        case .searchURL:
            return "Search"
        case .streamURL:
            return ""
        }
    }
    
    func getURL() -> String {
        switch self {
        case .allMusicURL:
            return "Aall-music"
        case .allAudioURL:
            return "Aall-audio"
        case .alternativerockURL:
            return "Aalternativerock"
        case .ambientURL:
            return "Aambient"
        case .classicalURL:
            return "Aclassical"
        case .countryURL:
            return "Acountry"
        default:
            return "Aall-music"
        }
    }
}
