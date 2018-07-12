//
//  UIViewController-Extension.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/12.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func show (_ title: String?, content: String, cancel: String?) {
        let vc = UIAlertController.init(title: title, message: content, preferredStyle: .alert)
        vc.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
}
