//
//  DetailPersonalController.swift
//  DMusic
//
//  Created by Ledung95d on 9/17/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import Reusable
import CoreData
import AVFoundation

class DetailPersonalController: UIViewController, NIBBased {
    
    private var downloadTracks = [DownloadTrack]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<DownloadTrackData>!
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var test: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cellType: TrackCell.self)
        loadData()
    }
    
    func loadData() {
        let request = DownloadTrackData.fetchRequest() as NSFetchRequest<DownloadTrackData>
        do {
            let result = try context.fetch(request)
            for data in result as [DownloadTrackData] {
                let downloadTrack = DownloadTrack()
                let track = Track(artwork_url: data.artwork_url,
                                  duration: data.duration,
                                  genre: data.genre,
                                  id: data.id,
                                  title: data.title)
                downloadTrack.track = track
                guard let urlLocal = data.url_local else { return }
                print("urlLocal; \(urlLocal)")
                print("title: \(data.title)")
                downloadTrack.urlLocal = urlLocal
                downloadTracks.append(downloadTrack)
            }
            tableView.reloadData()
            
        } catch {
            print("Failed")
        }
    }
}

extension DetailPersonalController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TrackCell
        cell.fill(track: downloadTracks[indexPath.row].track)
        return cell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlMusic = URL.init(string: downloadTracks[indexPath.row].urlLocal)
        let apPlayer = AVPlayer.init(url: urlMusic!)
        let avPlayerLayer = AVPlayerLayer.init(player: apPlayer)
        avPlayerLayer.frame = self.test.frame
        self.view.layer.addSublayer(avPlayerLayer)
        apPlayer.play()
    }
}

