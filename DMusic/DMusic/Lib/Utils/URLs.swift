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
    private static let ComponentUrl = "/charts?kind=top&genre=soundcloud%3Agenres%3"
    public static let APISearchUrl = String(format: "%@%@&client_id=%@", APIBaseUrl, LinkURL.searchURL.rawValue, APIKey.CliendId)
    
    static func getLinkGeneric(_ linkURL: LinkURL) ->String {
        return String(format: "%@%@%@&client_id=%@", APIBaseUrl, ComponentUrl, linkURL.getURL(), APIKey.CliendId)
    }
}

public enum LinkURL: Int {
    case allMusicURL, allAudioURL,
    alternativerockURL, ambientURL,
    classicalURL, countryURL, searchURL
    
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
