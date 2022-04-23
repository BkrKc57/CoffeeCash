//
//  ApplicationData.swift
//  SoundojiApp
//
//  Created by MacOS on 19.04.2022.
//

import Foundation
import UIKit


enum UserType {
    case customer
    case cashier
    
    var uuidKey: String {
        switch self {
        case .cashier:
            return "COFFEECASHIER"
        case .customer:
            return "COFFEECUSTOMER"
        }
    }
}

class ApplicationData: NSObject {

    static let shared = ApplicationData()
    
    let uuid: String = UIDevice.current.identifierForVendor!.uuidString
    
    var userType: UserType!
    var qrUUID: String!
    
}
