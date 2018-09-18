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

class DetailPersonalController: BaseUIViewcontroller, NIBBased {
    
    private struct Constant {
        static let heightCell = 100
    }
    private var downloadTracks = [DownloadTrack]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<DownloadTrackData>!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    
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
                downloadTrack.urlLocal = urlLocal
                downloadTracks.append(downloadTrack)
            }
            tableView.reloadData()
            
        } catch {
            print("Failed")
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension DetailPersonalController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heightTableView.constant = CGFloat(downloadTracks.count * DetailPersonalController.Constant.heightCell)
        return downloadTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TrackCell
        cell.fill(track: downloadTracks[indexPath.row].track)
        return cell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var trackArray = [Track]()
        for item in downloadTracks {
            guard let track = item.track else { break }
            track.downloadLocal = item.urlLocal
            trackArray.append(track)
        }
        TrackTool.shared.tracks = trackArray
        TrackTool.shared.isOnline = false
        TrackTool.shared.setTrackMesseage(track: trackArray[indexPath.row])
        let popUpController = PopupController.instantiate()
        self.navigationController?.present(popUpController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let request = DownloadTrackData.fetchRequest() as NSFetchRequest<DownloadTrackData>
            request.predicate = NSPredicate(format: "id = %d", downloadTracks[indexPath.row].track.id)
            do {
                let result = try context.fetch(request)
                let trackModel = downloadTracks[indexPath.row]
                for item in result as! [DownloadTrackData] {
                    print("item: \(item.id)")
                    if item.id == trackModel.track.id {
                        context.delete(item)
                    }
                }
            } catch let error {
                print("delete error; \(error)")
            }
            downloadTracks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
