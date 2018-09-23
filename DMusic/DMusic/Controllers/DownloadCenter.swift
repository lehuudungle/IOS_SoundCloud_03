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
    static let shared = DownloadCenter()
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<DownloadTrackData>!
    var trackMessage = TrackTool.shared.trackMessage
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var isDownloading = false
    var trackId: Int64 = 0
    var userInfo = [String: Double]()
    var arrayDownByTrack = [Track]()
    var dictURLTrack = [Int64: String]()
    
    
    func updateArrayDownById(downloadTrack: Track) {
        
        //        if dictURLTrack[idTrack] == nil {
        //            arrayDownByID.append(idTrack)
        //            dictURLTrack[idTrack] = "\(self.getSaveFileUrl(idTrack: "\(idTrack)"))"
        //        }
        //        // if trong array download ma chi co 1 phan tu thi thu hien download
        //        if arrayDownByID.count == 1 {
        //            getTrackFromServer(idTrack: idTrack)
        //        }
        arrayDownByTrack.append(downloadTrack)
        print("so phan tu Array: \(arrayDownByTrack.count)")
        if arrayDownByTrack.count == 1 {
            getTrackFromServer(downloadTrack)
        }
        
    }
    
    func positionDownload(downloadTrack: Track) -> Int {
        return arrayDownByTrack.index{ $0.id == downloadTrack.id } ?? -1
    }
    
    func getTrackFromServer(_ downloadTrack: Track) {
        if arrayDownByTrack.count == 0 {
            return
        }
        let filePathTrack = self.getSaveFileUrl(idTrack: "\(downloadTrack.id)")
        trackListRepository.downloadForSong(idTrack: downloadTrack.id,
                                            saveURL: filePathTrack,
                                            dowloadProgress: { (numberProgress) in
                                                print("numberP: \(downloadTrack.id): \(numberProgress)")
                                                self.userInfo["percentDownload"] = numberProgress
                                                self.userInfo["idTrack"] = Double(downloadTrack.id)
                                                NotificationCenter.default.post(name: Notification.Name("percentDownload:\(downloadTrack.id)"), object: nil, userInfo: self.userInfo)
                                                
        }, completion: {
            print("download thanh cong")
            self.saveTrack(filePathTrack, trackModel: self.arrayDownByTrack.first!)
            self.arrayDownByTrack.removeFirst()
            print("so phan tu sau khi download xong: \(self.arrayDownByTrack.count)")
            if self.arrayDownByTrack.count > 0 {
                self.getTrackFromServer(self.arrayDownByTrack.first!)
            }
        })
    }
    
    func getSaveFileUrl(idTrack: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = URL(string: idTrack)
        let fileURL = documentsURL.appendingPathComponent((nameUrl!.lastPathComponent)).appendingPathExtension("mp3")
        print("duong link: \(fileURL)")
        return fileURL;
    }
    
    func saveTrack(_ saveURL: URL, trackModel: Track) {
        let downloadData = DownloadTrackData(entity: DownloadTrackData.entity(), insertInto: context)
       
        print("saveData: \(trackModel.id) ___\(trackModel.title)")
        downloadData.artwork_url = trackModel.artwork_url
        downloadData.duration = Int64(trackModel.duration)
        downloadData.id = trackModel.id
        downloadData.url_local = "\(saveURL)"
        downloadData.title = trackModel.title
        downloadData.genre = trackModel.genre
        appDelegate.saveContext()
    }
}
