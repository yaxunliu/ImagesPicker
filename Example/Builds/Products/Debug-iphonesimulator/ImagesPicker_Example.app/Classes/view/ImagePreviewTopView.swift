//
//  ImagePreviewTopView.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public class FocalButton: UIButton {
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var newBounds = self.bounds
        let widthDelta = max(44.0 - newBounds.width, 0)
        let heightDelta = max(44.0 - newBounds.height, 0)
        newBounds = newBounds.insetBy(dx: -0.5 * widthDelta , dy: -0.5 * heightDelta)
        return newBounds.contains(point)
    }
}


class ImagePreviewTopView: UIView {
    @IBOutlet weak var selectButton: FocalButton!
    @IBOutlet weak var backButton: FocalButton!
    
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
