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
    let bag = DisposeBag()
    
    lazy var navBar: NavBarView = {
        let nav = NavBarView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIApplication.shared.statusBarFrame.height + 44))
        nav.title = "相机胶卷"
        nav.rightTitle = "取消"
        return nav
    }()
    var collectionView: UICollectionView?
    let column: CGFloat = 4
    var album: AlbumItem?
    var albumSection: BehaviorRelay<[ImagepPickerSectionModel]> = BehaviorRelay.init(value: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAllImages()
        observer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(navBar)
        if let title = album?.title {
            self.navBar.title = title
        }
        let layout = UICollectionViewFlowLayout.init()
        let itemWidth = (UIScreen.main.bounds.width - (column - 1.0) * 5.0) / column
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        })
        let nib = UINib.init(nibName: "PickImageCell", bundle: Bundle.init(for: ImagePickerController.self))
        collectionView?.register(nib, forCellWithReuseIdentifier: "PickImageCell")
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<ImagepPickerSectionModel>.init(configureCell: { [unowned self] (ds, collection, index, model) -> UICollectionViewCell in
            let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "PickImageCell", for: index) as! PickImageCell
            cell.model = model

            return cell
        })
        albumSection
            .bind(to: (collectionView?.rx.items(dataSource: dataSource))!)
            .disposed(by: bag)
    }
    
    
    
}

extension ImagePickerController {
    
    func observer() {
        navBar.rightButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.navigationController?.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)
        navBar.backButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: bag)
    }
}

extension ImagePickerController {
    
    func loadAllImages() {
        var models: [ImagePickerModel] = []
        for i in 0..<(self.album?.fetchResult.count)! {
            let asset = self.album?.fetchResult[i]
            let model = ImagePickerModel(asset: asset!)
            models.append(model)
        }
        self.albumSection.accept([ImagepPickerSectionModel.init(header: "imagePicker", images: models)])
    }
    
}

