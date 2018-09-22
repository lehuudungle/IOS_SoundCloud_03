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
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    
    @IBOutlet weak var titleDetail: UILabel!
    private var downloadTracks = [DownloadTrack]()
    private var favoriteTracks = [Track]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<DownloadTrackData>!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var positionview = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cellType: TrackCell.self)
        if positionview == 0 {
            loadDownloadData()
            titleDetail.text = "Download"
        } else {
            titleDetail.text = "Favorite"
            loadFavoriteData()
        }
        
    }
    
    func loadDownloadData() {
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
    
    func loadFavoriteData() {
        let request = FavoriteTrackData.fetchRequest() as NSFetchRequest<FavoriteTrackData>
        do {
            let result = try context.fetch(request)
            for data in result as [FavoriteTrackData] {
                let favoriteTrack = Track(artwork_url: data.artwork_url,
                                  duration: data.duration,
                                  genre: data.genre,
                                  id: data.id,
                                  title: data.title)
                favoriteTracks.append(favoriteTrack)
            }
            print("so phan tu Favorite: \(favoriteTracks.count)")
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
        
        if positionview == 0 {
            heightTableView.constant = CGFloat(downloadTracks.count * DetailPersonalController.Constant.heightCell)
            return downloadTracks.count
        } else if positionview == 1 {
             heightTableView.constant = CGFloat(favoriteTracks.count * DetailPersonalController.Constant.heightCell)
            print("count fa: \(favoriteTracks.count)")
            return favoriteTracks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TrackCell
        switch positionview {
        case 0:
            cell.fill(track: downloadTracks[indexPath.row].track)
        case 1:
            print("name Favorite: \(favoriteTracks[indexPath.row].title)")
            cell.fill(track: favoriteTracks[indexPath.row])
        default:
            break
        }
        return cell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var trackArray = [Track]()
        
        switch positionview {
        case 0:
            for item in downloadTracks {
                guard let track = item.track else { break }
                track.downloadLocal = item.urlLocal
                trackArray.append(track)
            }
            TrackTool.shared.isOnline = false
        case 1:
            trackArray = favoriteTracks
            TrackTool.shared.isOnline = true
            
        default:
            break
        }
        TrackTool.shared.tracks = trackArray
        TrackTool.shared.setTrackPlayer(track: trackArray[indexPath.row])
        let popUpController = PopupController.instantiate()
        self.navigationController?.present(popUpController, animated: true, completion: nil)

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if positionview == 0 {
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
            } else if positionview == 1 {
                let request = FavoriteTrackData.fetchRequest() as NSFetchRequest<FavoriteTrackData>
                request.predicate = NSPredicate(format: "id = %d", favoriteTracks[indexPath.row].id)
                do {
                    let result = try context.fetch(request)
                    let trackModel = favoriteTracks[indexPath.row]
                    for item in result as! [FavoriteTrackData] {
                        print("item: \(item.id)")
                        if item.id == trackModel.id {
                            context.delete(item)
                        }
                    }
                } catch let error {
                    print("delete error; \(error)")
                }
                favoriteTracks.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

extension DetailPersonalController {
    override func remoteControlReceived(with event: UIEvent?) {
        if let event  = event  {
            if event.type == .remoteControl {
                switch event.subtype {
                case .remoteControlPlay:
                    
                    TrackTool.shared.playTrack()
                    print("play")
                case .remoteControlPause:
                    TrackTool.shared.pauseTrack()
                    print("pause")
                case .remoteControlNextTrack:
                    TrackTool.shared.nextTrack()
                    print("nextTrack")
                case .remoteControlPreviousTrack:
                    TrackTool.shared.previousTrack()
                    print("previosuTrack")
                default:
                    print("Not display")
                }
                
            }
        }
    }
}
