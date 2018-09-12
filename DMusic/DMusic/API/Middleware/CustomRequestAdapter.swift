//
//  CustomRequestAdapter.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import Alamofire

class CustomRequestAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
