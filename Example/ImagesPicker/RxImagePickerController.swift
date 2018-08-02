//
//  RxImagePickerController.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/8/2.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import ImagesPicker

class RxImagePickerController: UINavigationController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let vc = AlbumListController(selectImages: { (models) in
            
        }, maxSelectNum: 9)
        self.pushViewController(vc, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
