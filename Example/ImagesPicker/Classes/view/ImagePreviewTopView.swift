//
//  ImagePreviewTopView.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class ImagePreviewTopView: UIView {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var backButton: UIButton!    
    
    class func loadFromNib() -> ImagePreviewTopView {
        return UINib.init(nibName: "ImagePreviewTopView", bundle: Bundle.init(for: ImagePreviewTopView.self)).instantiate(withOwner: nil, options: nil)[0] as! ImagePreviewTopView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backButton.setImage(ImageResource.back.image, for: .normal)
        self.selectButton.imageView?.contentMode = .center
        self.selectButton.setBackgroundImage(ImageResource.checkBox.image, for: .selected)
        self.selectButton.setBackgroundImage(ImageResource.uncheckBox.image, for: .normal)
    }
    
}
