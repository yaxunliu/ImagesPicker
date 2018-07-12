//
//  ImagepPickerModel.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import Photos
import RxDataSources


public struct ImagePickerModel {
    let asset: PHAsset    // 图片资源文件
    let identify: String  // 标识符
}


public struct ImagePickerSectionModel {
    var header: String
    var images: [ImagePickerModel]
}

extension ImagePickerSectionModel: SectionModelType {
    
    public typealias Item = ImagePickerModel
    public typealias Identity = String
    public var items: [Item] {
        return images
    }
    
    public var identity: String { return header }
    
    public init(original: ImagePickerSectionModel, items: [Item]) {
        self = original
        images = items
    }
}
