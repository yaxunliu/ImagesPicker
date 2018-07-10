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
    let asset: PHAsset
}


public struct ImagepPickerSectionModel {
    var header: String
    var images: [ImagePickerModel]
}

extension ImagepPickerSectionModel: SectionModelType {
    
    public typealias Item = ImagePickerModel
    public typealias Identity = String
    public var items: [Item] {
        return images
    }
    
    public var identity: String { return header }
    
    public init(original: ImagepPickerSectionModel, items: [Item]) {
        self = original
        images = items
    }
}
