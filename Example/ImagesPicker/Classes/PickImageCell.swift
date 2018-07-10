//
//  PickImageCell.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/9.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import Photos
class PickImageCell: UICollectionViewCell {

    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    var bag: DisposeBag?
    
    var model: ImagePickerModel? {
        didSet {
            self.bag = DisposeBag()
            guard let assets = model?.asset else { return }
            let manger = PHImageManager()
            let option = PHImageRequestOptions()
            option.resizeMode = .exact
            manger.requestImage(for: assets, targetSize: CGSize(width: UIScreen.main.scale * self.frame.width, height: UIScreen.main.scale * self.frame.height), contentMode: .aspectFill, options: nil) { (image, info) in
                self.photoImageView.image = image
            }
        }
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
}

