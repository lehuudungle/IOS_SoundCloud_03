//
//  APIService.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import Reachability

struct APIService {
    static let shared = APIService()
    private var alamofireManager = Alamofire.SessionManager.default
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
        alamofireManager.adapter = CustomRequestAdapter()
    }
    
    func request<T: Mappable>(input: BaseRequest, completion: @escaping (_ value: T?,_ error: BaseError?) -> Void) {
        print("\n------------REQUEST INPUT")
        print("link: %@", input.url)
        print("body: %@", input.body ?? "No Body")
        print("------------ END REQUEST INPUT\n")
        let reachability = Reachability()!
        reachability.whenReachable = { reachability in
            self.alamofireManager.request(input.url, method: input.requestType, parameters: input.body, encoding: input.encoding)
                .validate(statusCode: 200..<500)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let statusCode = response.response?.statusCode {
                            if statusCode == 200 {
                                let object = Mapper<T>().map(JSONObject: value)
                                completion(object, nil)
                            } else {
                                if let error = Mapper<ErrorResponse>().map(JSONObject: value) {
                                    completion(nil, BaseError.apiFailure(error: error))
                                } else {
                                    completion(nil, BaseError.httpError(httpCode: statusCode))
                                }
                            }
                        } else {
                            completion(nil, BaseError.unexpectedError)
                        }
                        break
                    case .failure(let error):
                        completion(nil, error as? BaseError)
                        break
                    }
            }
        }
        reachability.whenUnreachable = { reachability in
            completion(nil, BaseError.networkError)
        }
        
        try! reachability.startNotifier()
    }
}
