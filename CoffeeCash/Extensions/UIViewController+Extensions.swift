//
//  UIViewController+Extensions.swift
//  CoffeeCash
//
//  Created by MacOS on 23.04.2022.
//

import Foundation
import UIKit

extension UIViewController {
    func back() {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
