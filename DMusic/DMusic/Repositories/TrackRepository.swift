//
//  TrackRepository.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

protocol TrackRepository {
    
    func fetchListOfSongs(linkURL: LinkURL,
                          limit: Int,
                          offset: Int,
                          completion: @escaping (BaseResult<TracksResponse>) -> Void)
    
    func searchForSongsByKey(key: String?,
                             limit: Int,
                             offset: Int,
                             completion: @escaping (BaseResult<SearchResultTracks>) -> Void)
    
    func downloadForSong(idTrack: Int64,
                         saveURL: URL,
                         dowloadProgress: @escaping (_ numberProgress: Double) -> (),
                         completion: @escaping () -> ())
}

class TrackRepositoryImpl: TrackRepository {
    
    private var api: APIService!
    
    required init(api: APIService) {
        self.api = api
    }
    
    func fetchListOfSongs(linkURL: LinkURL,
                          limit: Int,
                          offset: Int,
                          completion: @escaping (BaseResult<TracksResponse>) -> Void) {
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
    
    func searchForSongsByKey(key: String?,
                             limit: Int,
                             offset: Int,
                             completion: @escaping (BaseResult<SearchResultTracks>) -> Void) {
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
    
    func downloadForSong(idTrack: Int64, saveURL: URL, dowloadProgress: @escaping (Double) -> (), completion: @escaping () -> ()) {
        guard  let downloadURL = URL(string: URLs.getStreamURL(id: idTrack)) else { return }
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (saveURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(downloadURL, to:destination)
            .downloadProgress { (progress) in
                dowloadProgress(progress.fractionCompleted)
            }
            .responseData { (data) in
                print("Completion")
                print("data bai hat: \(data)")
                completion()
        }
    }
}
