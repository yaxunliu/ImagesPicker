//
//  UIView-Extension.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public extension UIView {
    /*
     * 弹性动画
     */
    func show(bigger: Bool) {
        let animationScale1 = bigger ? 1.15 : 0.5
        let animationScale2 = bigger ? 0.92 : 1.15
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.layer.setValue(animationScale1, forKeyPath: "transform.scale")
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.layer.setValue(animationScale2, forKeyPath: "transform.scale")
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                    self.layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: nil)
            })
        }
    }
    
    
    
}
