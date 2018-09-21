//
//  BaseNavigationController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class BaseUIViewcontroller: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    /*
    override func remoteControlReceived(with event: UIEvent?) {
        if let event  = event  {
            if event.type == .remoteControl {
                switch event.subtype {
                case .remoteControlPlay:
                    TrackTool.shared.playTrack()
                    print("playTrack")
                case .remoteControlPause:
                    TrackTool.shared.pauseTrack()
                    print("pauseTrack")
                case .remoteControlNextTrack:
                    TrackTool.shared.nextTrack()
                    print("nextTrack")
                case .remoteControlPreviousTrack:
                    TrackTool.shared.previousTrack()
                    print("preTrack")
                default:
                    print("Not display")
                }
                
            }
        }
    }
 */
}
