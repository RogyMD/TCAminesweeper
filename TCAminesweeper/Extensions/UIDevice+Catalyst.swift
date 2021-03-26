//
//  UIDevice+Catalyst.swift
//  TCAminesweeper
//
//  Created by Igor Bidiniuc on 26/03/2021.
//

import UIKit

public extension UIDevice {
    var isCatalystMacIdiom: Bool {
        if #available(iOS 14, *) {
            return UIDevice.current.userInterfaceIdiom == .mac
        } else {
            return false
        }
    }
}
