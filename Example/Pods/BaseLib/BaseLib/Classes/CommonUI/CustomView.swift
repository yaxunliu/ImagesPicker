//
//  CustomView.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/7/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public class CustomBarButtonItem: UIBarButtonItem {
    public var actionButton: UIButton
    public init(image: UIImage?, title: String?) {
        actionButton = UIButton(type: .custom)
        if image != nil {
            var size: CGSize = .zero
            if image!.size.width < 44 {
                size.width = 44
                size.height = (image?.size.height)!
                actionButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: (44 - image!.size.width) / 2)
            } else if image!.size.height < 44 {
                size.height = 44
                size.height = (image?.size.width)!
            }
            actionButton.frame = CGRect(origin: .zero, size: size)
        } else {
            actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            actionButton.setTitle(title, for: .normal)
            actionButton.sizeToFit()
        }
        actionButton.setImage(image, for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        super.init()
        self.customView = actionButton
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




// MARK: 图片在左 文字在右
public class IconButton: UIButton {
    
    fileprivate var _title = ""
    fileprivate var _animation = false
    override public func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        if title != nil {
            _title = title!
        }
    }
    
    func updateFrame(_ setText: String?, _ animation: Bool = false )  {
        self.setTitle(setText, for: .normal)
        let oldSize = self.bounds.size
        let size = sizeThatFits(self.bounds.size)
        if animation {
            UIView.animate(withDuration: 0.3) {
                self.frame = CGRect(x: self.frame.origin.x - (size.width - oldSize.width) , y: self.frame.origin.y, width: size.width, height: size.height)
            }
        } else {
            self.frame = CGRect(x: self.frame.origin.x - (size.width - oldSize.width) , y: self.frame.origin.y, width: size.width, height: size.height)
        }
    }
    
    
    public init(image: UIImage?, title: String?) {
        super.init(frame: .zero)
        if title != nil {
            _title = title!
        }
        self.setTitle(title, for: .normal)
        self.setImage(image, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        self.setTitleColor(UIColor.getColor(hex: "333333"), for: .normal)
    }
    
    var space: CGFloat = 10.0
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        if _title.count == 0 {
            return rect
        }
        return CGRect(x: rect.origin.x + space * 0.5, y: rect.origin.y, width: rect.width, height: rect.height)
    }
    
    override public func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        if _title.count == 0 {
            return rect
        }
        return CGRect(x: rect.origin.x - space * 0.5, y: rect.origin.y, width: rect.width, height: rect.height)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let rect = super.sizeThatFits(size)
        if _title.count == 0 {
            return rect
        }
        return CGSize(width: rect.width + space, height: rect.height)
    }
    
    
}

// MARK: 文字在左 图片在右 带间距
public class IconMoreButton: UIButton {
    
    fileprivate var _image = UIImage()
    fileprivate var _selectImage = UIImage()
    fileprivate var _normalTitle = ""
    fileprivate var _selectTitle = ""
    
    override public func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        if image == nil { return }
        
        if state == .normal {
            _image = image!
        } else if state == .selected {
            _selectImage = image!
        }
    }
    
    
    override public func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        if title == nil { return }
        if state == .normal {
            _normalTitle = title!
        } else if state == .selected {
            _selectTitle = title!
        }
    }
    
    
    public init(image: UIImage?, title: String?) {
        super.init(frame: .zero)
        if image != nil {
            _image = image!
        }
        
        self.setTitle(title, for: .normal)
        self.setImage(image, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.setTitleColor(UIColor.getColor(hex: "999999"), for: .normal)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        
        if self.isSelected {
            return CGRect(x: rect.origin.x - _selectImage.size.width - 4, y: rect.origin.y, width: rect.width, height: rect.height)
        }
        return CGRect(x: rect.origin.x - _image.size.width - 4, y: rect.origin.y, width: rect.width, height: rect.height)
    }
    
    override public func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        
        if self.isSelected {
            
            self.titleLabel?.text = _selectTitle
            self.titleLabel?.sizeToFit()
            guard let width = self.titleLabel?.bounds.size.width else {
                return CGRect(x: 8, y: rect.origin.y, width: rect.width, height: rect.height)
            }
            return CGRect(x: width + 8, y: rect.origin.y, width: rect.width, height: rect.height)
        }
        return CGRect(x: (self.titleLabel?.bounds.width)! + 8, y: rect.origin.y, width: rect.width, height: rect.height)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let rect = super.sizeThatFits(size)
        
        if self.isSelected {
            self.titleLabel?.text = _selectTitle
            self.titleLabel?.sizeToFit()
            guard let width = self.titleLabel?.bounds.size.width else {
                return CGSize(width: 8.0 + _selectImage.size.width, height: rect.height)
            }
            return CGSize(width: width + 8.0 + _selectImage.size.width, height: rect.height)
        }
        return CGSize(width: rect.width + 8, height: rect.height)
    }
    
}

