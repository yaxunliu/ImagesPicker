//
//  ImagesPickerController.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/9.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Photos
import RxDataSources
import SnapKit


class ImagePickerController: UIViewController {
    lazy var navBar: NavBarView = {
        let nav = NavBarView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIApplication.shared.statusBarFrame.height + 44))
        nav.title = "相机胶卷"
        nav.rightTitle = "取消"
        return nav
    }()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let itemWidth = (UIScreen.main.bounds.width - (column - 1.0) * 5.0) / column
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        _itemSize = CGSize(width: itemWidth * UIScreen.main.scale, height: itemWidth * UIScreen.main.scale)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        let nib = UINib.init(nibName: "PickImageCell", bundle: Bundle.init(for: ImagePickerController.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "PickImageCell")
        return collectionView
    }()
    let accessView: ImagePickerAccessView = ImagePickerAccessView.loadFromNib()
    let bag = DisposeBag()
    private var _itemSize: CGSize = .zero
    private lazy var _imageCacheManger: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    private var _previousPreheatRect: CGRect = .zero
    let column: CGFloat = 4
    var album: AlbumItem?
    var albumSection: BehaviorRelay<[ImagepPickerSectionModel]> = BehaviorRelay.init(value: [])
    /// 减少/增加 选择的图片
    var oprationAction: BehaviorSubject<(isAddAction: Bool?, imageModel: ImagePickerModel?)?> = BehaviorSubject(value: nil)
    var selectImages: BehaviorRelay<[ImagePickerModel]> = BehaviorRelay(value: [])
    var selectImageBlock: ([ImagePickerModel]) -> ()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    //MARk: 初始化方法
    init(selectImages: @escaping ([ImagePickerModel]) -> ()) {
        selectImageBlock = selectImages
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateCacheAsset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1.设置UI
        setupUI()
        // 2.绑定数据源
        bindDataSource()
        // 3.加载数据
        loadAllImages()
        // 4.监听UI
        observer()
    }
    
}

extension ImagePickerController {
    
    // 1.设置UI
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(navBar)
        view.addSubview(accessView)
        view.addSubview(collectionView)
        if let title = album?.title {
            self.navBar.title = title
        }
        navBar.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(navBar.frame.height)
        }
        let height = UIApplication.shared.statusBarFrame.height == 20 ? 0 : 34
        accessView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(81 + height)
        }
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.equalTo(accessView.snp.top)
        }
        
    }
    
    // 2.绑定数据源
    func bindDataSource() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<ImagepPickerSectionModel>.init(configureCell: { [unowned self] (ds, collection, index, model) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PickImageCell", for: index) as! PickImageCell
            cell.model = model
            self._imageCacheManger.requestImage(for: model.asset, targetSize: self._itemSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
                if cell.model?.identify == model.asset.localIdentifier {
                    cell.photoImageView.image = image
                }
            })
            self.selectImages
                .bind(to: cell.obserSelectModels)
                .disposed(by: cell.bag!)
            cell.pickButton.rx
                .controlEvent([.touchUpInside])
                .map{ cell.status == .unenable }
                .map{ $0 ? nil : (cell.status == .unselect ? true : false) }
                .map{ (isAddAction: $0, imageModel: cell.model) }
                .bind(to: self.oprationAction)
                .disposed(by: cell.bag!)
            return cell
        })
        albumSection
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        collectionView.rx.didScroll.asObservable().subscribe { [unowned self] _ in
            self.updateCacheAsset()
            }.disposed(by: bag)
        
        collectionView.performBatchUpdates(nil, completion: { [unowned self] _ in
            if self.collectionView.contentSize.height > self.collectionView.bounds.height {
                self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - self.collectionView.bounds.height), animated: false)
            }
        })
    }
    
    // 3.加载数据
    func loadAllImages() {
        var models: [ImagePickerModel] = []
        for i in 0..<(self.album?.fetchResult.count)! {
            let asset = self.album?.fetchResult[i]
            let model = ImagePickerModel.init(asset: asset!, identify: asset!.localIdentifier)
            models.append(model)
        }
        models.reverse()
        self.albumSection.accept([ImagepPickerSectionModel.init(header: "imagePicker", images: models)])
        self.accessView.numLabel.text = "共\(models.count)张照片"
    }
    
}


extension ImagePickerController {

    func observer() {
        // 1.监听点击
        observerSelectTap()
        // 2.处理增加和删除
        observerRemoveOrAdd()
        // 3.监听预览
        observerPreview()
        // 4.监听退出
        observeEnd()
    }
    
    func observerPreview() {
        self.accessView.previewButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            let preVc = ImagePreviewController(previewAssets: self.selectImages.value, begin: 0, selected: self.selectImages.value) { [unowned self] (models, status) in
                self.selectImages.accept(models)
                if status == .dismiss {
                    self.selectImageBlock(self.selectImages.value)
                }
            }
            self.navigationController?.pushViewController(preVc , animated: true)
        }.disposed(by: bag)
        
        self.collectionView.rx.itemSelected.asObservable().subscribe { [unowned self] event in
            guard let index = event.element else { return }
            let preVc = ImagePreviewController(previewAssets: self.albumSection.value[0].images, begin: index.row, selected: self.selectImages.value) { [unowned self] (models, status) in
                self.selectImages.accept(models)
                if status == .dismiss {
                    self.selectImageBlock(self.selectImages.value)
                }
            }
            self.navigationController?.pushViewController(preVc , animated: true)
        }.disposed(by: bag)
        
    }
    
    func observeEnd() {
        self.accessView.ensureButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.selectImageBlock(self.selectImages.value)
        }.disposed(by: bag)
        
        navBar.rightButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.navigationController?.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)
        
        navBar.backButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: bag)
    }
    
}


//MARK: 图片选择逻辑
extension ImagePickerController {
    
    // 1.选择按钮点击
    func observerSelectTap() {
        // 确认按钮是否可以点击
        self.selectImages.asDriver()
            .map{ $0.count > 0}
            .asObservable()
            .subscribe({ [unowned self] (event) in
                guard let enable = event.element else { return }
                self.accessView.ensureButton.isEnabled = enable
                let color = !enable ? UIColor.getColor(hex: "b1b1b1") : UIColor.getColor(hex: "047fd5")
                self.accessView.ensureButton.backgroundColor = color
                self.accessView.previewButton.isEnabled = enable
        }).disposed(by: bag)
    }
    
    // 2.添加或者移除图片
    func observerRemoveOrAdd() {
        // 添加选中图片和删除选中图片
        oprationAction.subscribe { [unowned self] (event) in
            let ele = event.element ?? nil
            let addAction = ele?.isAddAction
            if addAction == nil { // 不能添加
                // TODO: 需要添加弹框提示 提示用户不能添加超过9张图片
                print("不能添加！！！！")
                return
            }
            guard let operation = ele else { return }
            var images = self.selectImages.value
            if operation.isAddAction! { // 添加
                if images.count <= 9 { images.append(operation.imageModel!) }
            } else { // 删除
                if images.count > 0 {
                    guard let index = images.index(where: { $0.identify == operation.imageModel!.identify }) else { return }
                    images.remove(at: index)
                }
            }
            self.selectImages.accept(images)
        }.disposed(by: bag)
    }
}


//MARK: 缓存优化
extension ImagePickerController {
    
    func initinalCache() {
        _imageCacheManger.stopCachingImagesForAllAssets()
    }
    
    func updateCacheAsset() {
        if !self.isViewLoaded || self.view.window == nil { return }
        // 预热区域 preheatRect 是 可见区域 visibleRect 的两倍高
        let visibelRect = CGRect(x: 0, y: self.collectionView.contentOffset.y, width: self.collectionView.bounds.width, height: self.collectionView.bounds.height)
        let preheatRect = visibelRect.insetBy(dx: 0, dy: -0.5 * self.collectionView.bounds.height)
        
        // 只有当可见区域与最后一个预热区域显著不同时才更新
        let del = fabs(preheatRect.midY - _previousPreheatRect.midY)
        if del > self.view.bounds.height / 3 {
            // 计算开始缓存和停止缓存的区域
            self.caculateDifference(oldRect: _previousPreheatRect, newRect: preheatRect, removeHanle: { [unowned self] (remove) in
                self.stopCacheImage(remove)
            }) { [unowned self] (add) in
                self.startCacheImage(add)
            }
            _previousPreheatRect = preheatRect
        }
    }
    
    func startCacheImage(_ rect: CGRect) {
        let startAssets = self.indexPaths(rect)
        _imageCacheManger.startCachingImages(for: startAssets, targetSize: _itemSize, contentMode: .aspectFill, options: nil)
    }
    
    func stopCacheImage(_ rect: CGRect) {
        let stopAssets = self.indexPaths(rect)
        _imageCacheManger.stopCachingImages(for: stopAssets, targetSize: _itemSize , contentMode: .aspectFill, options: nil)
    }
    
    func indexPaths(_ inRect: CGRect) -> [PHAsset]{
        let layout = self.collectionView.collectionViewLayout
        let attrs = layout.layoutAttributesForElements(in: inRect)
        var assets: [PHAsset] = []
        for attr in attrs! {
            let index = attr.indexPath
            guard let asset = self.album?.fetchResult[index.row] else { continue }
            assets.append(asset)
        }
        return assets
    }
    
    func caculateDifference(oldRect: CGRect, newRect: CGRect, removeHanle: (_ removeRect: CGRect)->(), addHanle: (_ addedRect: CGRect)->()) {
        // 两个范围相交
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            
            //添加 向下滑动时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addHanle(rectToAdd);
            }
            //添加 向上滑动时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addHanle(rectToAdd);
            }
            
            //移除 向上滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外底部的预热区域）
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removeHanle(rectToRemove);
            }
            //移除 向下滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外顶部的预热区域）
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removeHanle(rectToRemove);
            }
            
        } else { // 不相交
            addHanle(newRect)
            removeHanle(oldRect)
        }
        
        
    }
    
}

