//
//  Storyboards.swift
//  SoundojiApp
//
//  Created by MacOS on 18.04.2022.
//

import Foundation
import UIKit

enum StoryBoard: String {
    case main = "MainScreen"
    case customer = "CustomerScreen"
    case cashier = "CashierScreen"
    case scanner = "ScannerScreen"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    var vc: UIViewController {
        return self.instance.instantiateViewController(withIdentifier: self.rawValue + "ViewController")
    }
}

