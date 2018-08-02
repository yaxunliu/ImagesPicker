//
//  NavBarView.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/9.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BaseLib


class NavBarView: UIView {
    
    var titleLabel: UILabel = UILabel()
    var backButton: FocalButton = FocalButton(type: .custom)
    
    lazy var rightButton: FocalButton = {
        let btn = FocalButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    
    let barView: UIView = UIView()
    var rightTitle: String = "" {
        didSet {
            barView.addSubview(rightButton)
            rightButton.setTitle(rightTitle, for: .normal)
            rightButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let statusView = UIView()
        addSubview(statusView)
        addSubview(barView)
        titleLabel.font = UIFont.systemFont(ofSize: 19)
        titleLabel.textColor = .white
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle(" 返回", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        barView.addSubview(titleLabel)
        barView.addSubview(backButton)
        backButton.setImage(ImageResource.back.image , for: .normal)
        
        barView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        self.backgroundColor = UIColor.getColor(hex: "292933")
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
