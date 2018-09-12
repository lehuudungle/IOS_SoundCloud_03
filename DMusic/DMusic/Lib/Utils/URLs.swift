//
//  URLs.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
struct URLs {
    private static var APIBaseUrl = "https://api-v2.soundcloud.com"
    public static let APIGenresUrl = String(format: "%@%@&client_id=%@", APIBaseUrl, LinkUrl.genresUrl.rawValue, APIKey.CliendId)
    public static let APISearchUrl = String(format: "%@%@&client_id=%@", APIBaseUrl, LinkUrl.searchUrl.rawValue, APIKey.CliendId)
}

public enum LinkUrl: String {
    case genresUrl = "/charts?kind=top&genre=soundcloud%3Agenres%3Aall-music"
    case searchUrl = "/search/tracks?"
}
