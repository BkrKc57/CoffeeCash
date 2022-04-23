//
//  MainScreenViewController.swift
//  MeTechApp
//
//  Created by MacOS on 20.04.2022.
//

import UIKit

class MainScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: -- Actions
    
    @IBAction func customerButtonAction(_ sender: UIButton) {
        ApplicationData.shared.userType = .customer
        self.push(screen: .customer)
    }
    
    @IBAction func cashierButtonAction(_ sender: UIButton) {
        ApplicationData.shared.userType = .cashier
        self.presentInNav(screen: .scanner)
    }
}
