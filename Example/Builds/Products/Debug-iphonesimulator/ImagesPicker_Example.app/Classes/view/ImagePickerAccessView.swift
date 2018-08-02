//
//  ImagePickerAccessView.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class ImagePickerAccessView: UIView {

    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var ensureButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    
    
    class func loadFromNib() -> ImagePickerAccessView {
        return UINib.init(nibName: "ImagePickerAccessView", bundle: Bundle.init(for: ImagePickerAccessView.self)).instantiate(withOwner: nil, options: nil)[0] as! ImagePickerAccessView
    }

}
