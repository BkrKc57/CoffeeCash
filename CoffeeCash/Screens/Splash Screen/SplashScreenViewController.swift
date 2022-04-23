//
//  ViewController.swift
//  MeTechApp
//
//  Created by MacOS on 20.04.2022.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.push(screen: .main)
        }
    }


}

