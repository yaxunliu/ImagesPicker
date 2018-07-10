//
//  AlbumCell.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/9.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import Photos

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumCountLabel: UILabel!
    
    var album: AlbumItem? {
        didSet {
            self.albumTitleLabel.text = album?.title
            self.albumCountLabel.text = "(\(album!.fetchResult.count))"
            guard let result = album?.fetchResult else { return }
            if result.count > 0 {
                if let firstImageAsset = result[0] as PHAsset? {
                    let retinaMultiplier = UIScreen.main.scale
                    let realSize = self.albumImageView.frame.width * retinaMultiplier
                    let size = CGSize(width:realSize, height: realSize)
                    let imageOptions = PHImageRequestOptions()
                    imageOptions.resizeMode = .exact
                    PHImageManager.default().requestImage(for: firstImageAsset, targetSize: size, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, info) -> Void in
                        DispatchQueue.main.async {
                            self.albumImageView.image = image
                        }
                    })
                }
            }
        }
    }
    
    
    
}
