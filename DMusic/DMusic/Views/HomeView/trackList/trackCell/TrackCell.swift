//
//  TrackCell.swift
//  DMusic
//
//  Created by le.huu.dung on 9/11/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable
import NFDownloadButton
import CoreData

class TrackCell: UITableViewCell, NibReusable {

    private struct Constant {
        static let defaultGeneric = "No Generic"
        static let defaultTitleTrack = "No Track"
        static let defaultImage = #imageLiteral(resourceName: "personal_icon")
    }
    
    @IBOutlet private weak var trackImage: UIImageView!
    @IBOutlet private weak var nameTrackLabel: UILabel!
    @IBOutlet private weak var genericTrackLabel: UILabel!
    @IBOutlet weak var statusDownload: NFDownloadButton!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<DownloadTrackData>!
    var updatePercent: (() -> ())?
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    var trackCell = Track()
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fill(track: Track) {
        clearData()
        trackCell = track
        self.genericTrackLabel.text = track.genre
        nameTrackLabel.text = track.title
    
        if let url = URL(string: track.artwork_url) {
            self.trackImage.sd_setShowActivityIndicatorView(true)
            self.trackImage.sd_setIndicatorStyle(.gray)
            self.trackImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "personal_icon"), options: [.progressiveDownload], completed: nil)
        }
        if track.downloadURL.isEmpty {
            statusDownload.isHidden = true
            return
        } else {
            statusDownload.isHidden = false
            statusDownload.downloadState = .toDownload
            let request = DownloadTrackData.fetchRequest() as NSFetchRequest<DownloadTrackData>
            request.predicate = NSPredicate(format: "id CONTAINS[cd] %@", "\(track.id)")
            do{
                let downloadTracks: [DownloadTrackData] = try context.fetch(request)
                if downloadTracks.count > 0 {
                    statusDownload.downloadState = .downloaded
                    statusDownload.isHidden = false
                }
            }catch let error as NSError {
                print("error: \(error)")
            }
        }

         NotificationCenter.default.addObserver(self, selector: #selector(self.updatePercenDownload(notification:)), name: Notification.Name("percentDownload"), object: nil)

    }
    
    @IBAction func downloadAction(_ sender: NFDownloadButton) {
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePercenDownload(notification:)), name: Notification.Name("percentDownload"), object: nil)
 */
    }
    
    @objc func updatePercenDownload(notification: Notification) {
        let userInfo = notification.userInfo as! [String: Double]
        let trackId = Int64(userInfo["idTrack"]!)
        if trackCell.id == trackId {
            statusDownload.downloadPercent = CGFloat(userInfo["percentDownload"]!)
        }

    }
    
    
    func clearData() {
        self.genericTrackLabel.text = ""
        self.nameTrackLabel.text = ""
        self.trackImage.image = TrackCell.Constant.defaultImage

        //statusDownload.isHidden = true
    }
}
