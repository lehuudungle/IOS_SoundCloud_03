//
//  DownloadCenter.swift
//  DMusic
//
//  Created by le.huu.dung on 9/18/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DownloadCenter: NSObject {
//    static let shared = DownloadCenter()
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<DownloadTrackData>!
    var trackMessage = TrackTool.shared.trackMessage
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var isDownloading = false
    var trackId: Int64 = 0
    var userInfo = [String: Double]()
    func getTrackFromServer() {
        guard let trackModel = trackMessage.trackModel else { return }
        let filePathTrack = self.getSaveFileUrl(idTrack: "\(trackModel.id)")
        self.trackId = trackModel.id
        userInfo["idTrack"] = Double(trackModel.id)
        trackListRepository.downloadForSong(idTrack: trackModel.id,
                                            saveURL: filePathTrack,
                                            dowloadProgress: { (numberProgress) in
                                                print("numberP: \(trackModel.id): \(numberProgress)")
                                                self.userInfo["percentDownload"] = numberProgress
                                                NotificationCenter.default.post(name: Notification.Name("percentDownload"), object: nil, userInfo: self.userInfo)
                                            
        }, completion: {
            print("download thanh cong")
            self.saveTrack(filePathTrack)
        })
    }
    
    func getSaveFileUrl(idTrack: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = URL(string: idTrack)
        let fileURL = documentsURL.appendingPathComponent((nameUrl!.lastPathComponent)).appendingPathExtension("mp3")
        return fileURL;
    }
    
    func saveTrack(_ saveURL: URL) {
        let downloadData = DownloadTrackData(entity: DownloadTrackData.entity(), insertInto: context)
        guard let trackModel = trackMessage.trackModel else { return }
        downloadData.artwork_url = trackModel.artwork_url
        downloadData.duration = Int64(trackModel.duration)
        downloadData.id = trackModel.id
        downloadData.url_local = "\(saveURL)"
        downloadData.title = trackModel.title
        downloadData.genre = trackModel.genre
        appDelegate.saveContext()
    }
}
