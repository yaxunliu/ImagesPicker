//
//  PickImageCell.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/9.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Photos


public enum PickImageStatus {
    case unselect  // 未选中
    case select    // 选中
    case unenable  // 不能选中
}


public class PickImageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var pickButton: FocalButton!
    @IBOutlet weak var photoImageView: UIImageView!
    var status: PickImageStatus = .unselect

    var bag: DisposeBag?
    var obserSelectModels: BehaviorRelay<[ImagePickerModel]> = BehaviorRelay.init(value: [])
    var model: ImagePickerModel? {
        didSet {
            bag = DisposeBag()
            obserSelectModels.subscribe { [unowned self] (modelsEvent) in
                guard let selectModels = modelsEvent.element else { return }
                // 获取当前选中的下标
                guard let index = selectModels.index(where: { $0.identify == self.model?.identify }) else {
                    if selectModels.count >= 9 { // 未选中
                        self.status = .unenable
                        self.alpha = 0.5
                    } else {
                        self.status = .unselect
                        self.alpha = 1
                    }
                    self.pickButton.setTitle(nil, for: .normal)
                    self.pickButton.isSelected = false
                    return
                }
                // 选中
                self.alpha = 1
                
                if self.status == .unselect { // 动画
                    self.pickButton.setTitle("\(index + 1)", for: .normal)
                    self.pickButton.show(bigger: true)
                } else {
                    self.pickButton.setTitle("\(index + 1)", for: .normal)
                }
                self.pickButton.isSelected = true
                self.status = .select
            }.disposed(by: bag!)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.pickButton.imageView?.contentMode = .scaleAspectFit        
        self.pickButton.setBackgroundImage(ImageResource.checkBox.image, for: .selected)
        self.pickButton.setBackgroundImage(ImageResource.uncheckBox.image, for: .normal)
        self.pickButton.imageView?.contentMode = .center
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
        status = .unselect
    }
    
    deinit {
        bag = nil
    }
    
}
