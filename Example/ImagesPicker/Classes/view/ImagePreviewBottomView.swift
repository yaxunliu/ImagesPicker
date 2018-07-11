//
//  ImagePreviewBottomView.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class ImagePreviewBottomView: UIView {

    @IBOutlet weak var certainButton: UIButton!
    class func loadFromNib() -> ImagePreviewBottomView {
        return UINib.init(nibName: "ImagePreviewBottomView", bundle: Bundle.init(for: ImagePreviewTopView.self)).instantiate(withOwner: nil, options: nil)[0] as! ImagePreviewBottomView
    }

}
