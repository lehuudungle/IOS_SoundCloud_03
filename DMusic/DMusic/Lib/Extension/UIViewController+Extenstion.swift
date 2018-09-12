//
//  UIViewController+Extenstion.swift
//  DMusic
//
//  Created by le.huu.dung on 9/7/18.
//  Copyright © 2018 le.huu.dung. All rights reserved.
//

import Foundation
import UIKit

// MARK: Reusable for  file xib
protocol NIBBased {
    static var nibName: String { get }
}

extension NIBBased {
    static var nibName: String {
        return String.init(describing: self)
    }
}

extension NIBBased where Self: UIViewController {
    static func instantiate() -> Self {
        return Self.init(nibName: self.nibName, bundle: Bundle(for: self))
    }
}

extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect?) {
        addChildViewController(child)
        guard  let frame = frame else {return }
        child.view.frame = frame
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    func removeChild() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}
