//
//  ImageResource.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/11.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

enum ImageResource: String {
    case back = "ic_back@"       // 返回
    case checkBox = "img_blue@"    // 选中
    case uncheckBox = "img_black@" // 未选中
    case more = "ic_acce@"        // 更多
    
    var image: UIImage? {
        var imageName = ""
        if UIScreen.main.scale == 2.0 {
            imageName = self.rawValue + "2x"
        } else if UIScreen.main.scale == 3.0 {
            imageName = self.rawValue + "3x"
        } else {
            imageName = self.rawValue + "2x"
        }
        
        let bundle = Bundle.init(path: Bundle.init(for: ImagePreviewCell.self).bundlePath + "ImagesPicker.bundle")
        return UIImage.init(named: imageName, in: bundle, compatibleWith: nil)
    }
}


