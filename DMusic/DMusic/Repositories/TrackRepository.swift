//
//  TrackRepository.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import ObjectMapper

protocol TrackRepository {

    func fetchListOfSongs(linkURL: LinkURL, limit: Int, offset: Int, completion: @escaping (BaseResult<TracksResponse>) -> Void)
    
    func searchForSongsByKey(key: String?, limit: Int, offset: Int, completion: @escaping (BaseResult<SearchResultTracks>) -> Void)
}

class TrackRepositoryImpl: TrackRepository {
    
    private var api: APIService!
    
    required init(api: APIService) {
        self.api = api
    }
    
    func fetchListOfSongs(linkURL: LinkURL, limit: Int, offset: Int, completion: @escaping (BaseResult<TracksResponse>) -> Void) {
        let input = TrackListRequest(linkURL, limit: limit, offset: offset)
        api.request(input: input, completion: { (object: TracksResponse?, error) in
            guard let error = error else {
                if let object = object {
                    completion(.success(object))
                    return
                }
                completion(.failure(error: nil))
                return
            }
            completion(.failure(error: error))
        })
    }
    
    func searchForSongsByKey(key: String?, limit: Int, offset: Int, completion: @escaping (BaseResult<SearchResultTracks>) -> Void) {
        let input = TrackListRequest(key: key, limit: limit, offset: offset)
        api?.request(input: input, completion: { (object: SearchResultTracks?, error) in
            guard let error = error else {
                if let object = object {
                    completion(.success(object))
                    return
                }
                completion(.failure(error: nil))
                return
            }
            completion(.failure(error: error))
        })
    }
}
