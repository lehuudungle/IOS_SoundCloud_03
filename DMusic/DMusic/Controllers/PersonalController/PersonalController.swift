//
//  PersonalController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit
import CoreData

class PersonalController: BaseUIViewcontroller, NIBBased {
    
    @IBOutlet private weak var personalTable: UITableView!
    
    var titleImage = [#imageLiteral(resourceName: "download"), #imageLiteral(resourceName: "favorite")]
    var nameCell = ["Download", "Favorite]"]
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        personalTable.register(cellType: TitleCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        personalTable.reloadData()
    }
}

extension PersonalController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TitleCell
        switch indexPath.row {
        case 0:
            let request = DownloadTrackData.fetchRequest() as NSFetchRequest<DownloadTrackData>
            do {
//                cell.titleImage.image = titleImage[indexPath.row]
//                cell.nameLabel.text = nameCell[indexPath.row]
//                if indexPath.row == 0 {
//                    let result = try context.fetch(request)
//                    cell.numberTrack.text = "\(result.count)"
//                }
                let result = try context.fetch(request)
                cell.fill(nameTitle: nameCell[indexPath.row], titleImage: titleImage[indexPath.row], number: result.count)
                
            } catch {}
        case 1:
            let request = FavoriteTrackData.fetchRequest() as NSFetchRequest<FavoriteTrackData>
            do{
                let result = try context.fetch(request)
                cell.fill(nameTitle: nameCell[indexPath.row], titleImage: titleImage[indexPath.row], number: result.count)
            }catch {}
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailTracks = DetailPersonalController.instantiate()
        switch indexPath.row {
        case 0:
            detailTracks.positionview = 0
        case 1:
            detailTracks.positionview = 1
        default:
            return
        }
        self.navigationController?.pushViewController(detailTracks, animated: true)
    }
}

extension PersonalController {
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

