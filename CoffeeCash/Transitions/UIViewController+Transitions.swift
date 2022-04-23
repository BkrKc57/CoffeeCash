//
//  UIViewController+Transitions.swift
//  SoundojiApp
//
//  Created by MacOS on 18.04.2022.
//

import Foundation
import UIKit

extension UIViewController {
    
    // Push
    func push(screen: StoryBoard) {
        let vc = screen.vc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentInNav(screen: StoryBoard) {
        let vc = screen.vc
        let navContoller: UINavigationController = UINavigationController(rootViewController: vc)
        navContoller.isNavigationBarHidden = true
        self.present(navContoller, animated: true, completion: nil)
    }
}
