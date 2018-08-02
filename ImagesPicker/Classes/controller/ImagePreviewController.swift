//
//  ImagePreviewController.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxDataSources
import SnapKit
import Photos
import RxSwift
import RxCocoa
import BaseLib

public enum ExitStatus {
    case pop
    case dismiss
}



public class ImagePreviewController: UIViewController {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let collection = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collection.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "ImagePreviewCell")
        collection.isPagingEnabled = true
        
        return collection
    }()
    
    let showNav = BehaviorRelay.init(value: false)
    let topView: ImagePreviewTopView = ImagePreviewTopView.loadFromNib()
    let currentModel: BehaviorRelay<ImagePickerModel?> = BehaviorRelay.init(value: nil)
    let currentIndex: BehaviorRelay<Int> = BehaviorRelay.init(value: 0)
    let bottomView: ImagePreviewBottomView = ImagePreviewBottomView.loadFromNib()
    var oprationAction: BehaviorSubject<(isAddAction: Bool?, imageModel: ImagePickerModel?)?> = BehaviorSubject(value: nil)

    /// 数据源
    var sectiomModels: BehaviorRelay<[ImagePickerSectionModel]>?
    var totalAssets: [ImagePickerModel]
    var selectedAssets: BehaviorRelay<[ImagePickerModel]> = BehaviorRelay<[ImagePickerModel]>.init(value: [])
    
    var endPreviewAssets: ([ImagePickerModel], ExitStatus) -> ()?
    
    let bag = DisposeBag()
    fileprivate let _imageCacheManger = PHImageManager.default()

    
    /*
     * @pramas: previewAssets 将要预览的所有资源
     * @pramas: begin 开始预览的索引
     * @pramas: selected 已经选中的资源
     * @pramas: endPreview 结束选中的资源
     */
    public init(previewAssets: [ImagePickerModel], begin: Int, selected: [ImagePickerModel], endPreview: @escaping ([ImagePickerModel], ExitStatus) -> ()) {
        totalAssets = previewAssets
        currentIndex.accept(begin)
        sectiomModels = BehaviorRelay.init(value: [ImagePickerSectionModel.init(header: "preview", images: previewAssets)])
        currentModel.accept(previewAssets[begin])
        selectedAssets.accept(selected)
        endPreviewAssets = endPreview
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observer()
        bindDataSource()
        
    }
    
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override public var prefersStatusBarHidden: Bool { return true }

}

extension ImagePreviewController {
    
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(collectionView)
        view.addSubview(topView)
        view.addSubview(bottomView)
        view.backgroundColor = .yellow
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let statusH = UIScreen.screenEnum == .iPhoneX ? 44 : 20
        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(statusH + 44)
        }
        let bottomH = UIScreen.screenEnum == .iPhoneX ? 34 : 0
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44 + bottomH)
        }
    }
    
    func bindDataSource() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<ImagePickerSectionModel>.init(configureCell: { [unowned self] (ds, collection, index, model) -> UICollectionViewCell in
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "ImagePreviewCell", for: index) as! ImagePreviewCell

            if model.asset != nil {
                self._imageCacheManger.requestImage(for: model.asset!, targetSize: UIScreen.main.bounds.size, contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
                    cell.previewImageView.image = image
                    cell.model = model
                })
            }
            
            cell.tap?.rx.event.map({ [unowned self] _ in
                return !self.showNav.value
            }).bind(to: self.showNav).disposed(by: cell.bag!)
            return cell
        })
        sectiomModels?.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: bag)        
        collectionView.performBatchUpdates(nil) { [unowned self] _ in
            self.collectionView.setContentOffset(CGPoint(x: CGFloat(self.currentIndex.value) * self.collectionView.bounds.width, y: 0) , animated: false)
        }
        
    }
    
    func observer()  {
        /// 监听滚动事件
        observeScroll()
        /// 监听退出事件
        observerExit()
        /// 单击cell事件
        observeSingleTap()
        /// 监听选中和取消选中事件
        observerDeselectOrSelect()
    
    }
    
    func observeSingleTap() {
        showNav.subscribe { [unowned self] event in
            guard let show = event.element else { return }
            UIView.animate(withDuration: 0.3, animations: {
                self.topView.isHidden = show
                self.bottomView.isHidden = show
            })
        }.disposed(by: bag)
    }
    
    func observerExit() {
        topView.backButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.endPreviewAssets(self.selectedAssets.value, .pop)
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: bag)
        
        bottomView.certainButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.endPreviewAssets(self.selectedAssets.value, .dismiss)
        }.disposed(by: bag)
    }
    
    func observeScroll() {
        currentModel.subscribe { [unowned self] (event) in
            guard let model = event.element ?? nil else { return }
            guard let index = self.selectedAssets.value.index(where: { (selectModel) -> Bool in
                return selectModel.identify == model.identify
            }) else {
                self.topView.selectButton.isSelected = false
                self.topView.selectButton.setTitle(nil, for: .normal)
                return
            }
            self.topView.selectButton.isSelected = true
            self.topView.selectButton.setTitle("\(index + 1)", for: .normal)
        }.disposed(by: bag)
        
        collectionView.rx.didScroll.subscribe { [unowned self] _ in
            let offWidth = self.collectionView.contentOffset.x + self.collectionView.frame.width * 0.5
            let currentIndex = offWidth / self.collectionView.frame.width
            if currentIndex < CGFloat(self.totalAssets.count) && currentIndex != CGFloat(self.currentIndex.value) {
                self.currentIndex.accept(Int(currentIndex))
                self.currentModel.accept(self.totalAssets[Int(currentIndex)])
            }
        }.disposed(by: bag)
    }
    

}


// 添加或者取消选中
extension ImagePreviewController {
    
    func observerDeselectOrSelect() {
        // 1.粗发点击 选中或者取消
        topView.selectButton.rx
            .controlEvent([.touchUpInside])
            .map{ [unowned self] _ in
                self.topView.selectButton.isSelected || self.selectedAssets.value.count < 9
            }// >= 9 && isSelected = false
            .map { [unowned self] (canAdd) -> (isAddAction: Bool?, imageModel: ImagePickerModel?)? in
                if canAdd {
                    return (isAddAction: !self.topView.selectButton.isSelected, imageModel: self.totalAssets[self.currentIndex.value])
                }
                return (isAddAction: nil, imageModel: nil)
        }.bind(to: oprationAction).disposed(by: bag)
        
        // 2.添加选中图片和删除选中图片
        oprationAction.subscribe { [unowned self] (event) in
            let ele = event.element ?? nil
            let addAction = ele?.isAddAction
            guard let operation = ele else { return }
            if addAction == nil { // 不能添加
                self.show(nil, content: "你最多只能选择9张图片", cancel: "知道了")
                return
            }
            var images = self.selectedAssets.value
            if operation.isAddAction! { // 添加
                if images.count <= 9 {
                    images.append(operation.imageModel!)
                }
            } else { // 删除
                if images.count > 0 {
                    guard let index = images.index(where: { $0.identify == operation.imageModel!.identify }) else { return }
                    images.remove(at: index)
                }
            }
            self.selectedAssets.accept(images)
        }.disposed(by: bag)
        
        // 3.触发按钮的改变
        selectedAssets.subscribe { [unowned self] (event) in
            guard let models = event.element else { return }
            guard let selectIndex = models.index(where: { (model) -> Bool in
                return model.identify == self.currentModel.value?.identify
            }) else {
                // 取消选中
                self.topView.selectButton.isSelected = false
                self.topView.selectButton.setTitle(nil, for: .normal)
                return
            }
            self.topView.selectButton.isSelected = true
            self.topView.selectButton.setTitle("\(selectIndex + 1)", for: .normal)
            self.topView.selectButton.show(bigger: true)
        }.disposed(by: bag)
    }
    
}
