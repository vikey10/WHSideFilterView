//
//  Utility.swift
//  WHSideFilterViewDemo
//
//  Created by vikey wang on 4/21/17.
//  Copyright © 2017 vikey wang. All rights reserved.
//

import Foundation
import UIKit

let screen_width = UIScreen.main.bounds.size.width
let screen_height = UIScreen.main.bounds.size.height

class Utility: NSObject {
    //将颜色转为图片
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

}
