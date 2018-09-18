//
//  TrackListRequest.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation

class TrackListRequest: BaseRequest {
    required init(_ linkURL: LinkURL, limit: Int, offset: Int) {
        let body: [String: Any]  = [
            "limit": limit,
            "offset": offset
        ]
        super.init(url: URLs.getLinkGeneric(linkURL), requestType: .get, body: body)
    }
    
    required init(key: String?, limit: Int, offset: Int) {
        let searchKey = key == nil ? "" : key!
        let body: [String: Any]  = [
            "q": searchKey,
            "limit": limit,
            "offset": offset
        ]
        super.init(url: URLs.getSearchURL(), requestType: .get, body: body)
    }
}
