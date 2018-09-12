//
//  MainController.swift
//  DMusic
//
//  Created by le.huu.dung on 9/5/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import UIKit

class MainController: UITabBarController {
    
    private struct Constant  {
        static let heightTrackMessage: CGFloat = 60
    }
    static let shared = MainController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let homeController = HomeController.instantiate()
        let searchController = SearchController.instantiate()
        let personalController = PersonalController.instantiate()
        
        let homeRootController = BaseNavigationController(rootViewController: homeController)
        let searchRootController = BaseNavigationController(rootViewController: searchController)
        let personalRootController = BaseNavigationController(rootViewController: personalController)
        
        setupForEachRootController(viewcontroller: homeController,
                                   navTitle: TitleNavigator.HomeTitle,
                                   tabbarTitle: TitleNavigator.HomeTitle,
                                   unSelectedImage: #imageLiteral(resourceName: "home_icon"),
                                   selectedImage: #imageLiteral(resourceName: "home_icon_selected"))
        setupForEachRootController(viewcontroller: searchController,
                                   navTitle: TitleNavigator.SearchTitle,
                                   tabbarTitle: TitleNavigator.SearchTitle,
                                   unSelectedImage: #imageLiteral(resourceName: "search_icon"),
                                   selectedImage: #imageLiteral(resourceName: "search_icon_selected"))
        setupForEachRootController(viewcontroller: personalController,
                                   navTitle: TitleNavigator.PersonaTitle,
                                   tabbarTitle: TitleNavigator.PersonaTitle,
                                   unSelectedImage: #imageLiteral(resourceName: "personal_icon"),
                                   selectedImage: #imageLiteral(resourceName: "personal_icon_selected"))
        
        self.viewControllers = [homeRootController,
                                searchRootController,
                                personalRootController]

        let heightTabBar = self.tabBar.frame.height
        TrackMessageView.shared.view.frame = CGRect(x: 0, y:ScreenSize.heightScreen - MainController.Constant.heightTrackMessage - heightTabBar, width: ScreenSize.widthScreen, height: MainController.Constant.heightTrackMessage)
        self.view.addSubview(TrackMessageView.shared.view)
        TrackMessageView.shared.view.isHidden = true
        
        UITabBarItem.appearance()
            .setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.grayColor], for:.normal)
        UITabBarItem.appearance()
            .setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for:.selected)
        self.tabBar.backgroundColor = .whiteSmoke
    }
   
    func setupForEachRootController(viewcontroller: UIViewController,
                                    navTitle: String, tabbarTitle: String,
                                    unSelectedImage: UIImage,
                                    selectedImage: UIImage) {
        viewcontroller.navigationItem.title = navTitle
        viewcontroller.tabBarItem = UITabBarItem(title: tabbarTitle,
                                                 image:unSelectedImage
                                                    .withRenderingMode(.alwaysOriginal),
                                                 selectedImage: selectedImage
                                                    .withRenderingMode(.alwaysOriginal))
    }
}
