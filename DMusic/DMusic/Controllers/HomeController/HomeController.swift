//
//  HomeController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/6/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit

class HomeController: UIViewController, NIBBased {
    private let trackListRepository: TrackRepository = TrackRepositoryImpl(api: APIService.shared)
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
