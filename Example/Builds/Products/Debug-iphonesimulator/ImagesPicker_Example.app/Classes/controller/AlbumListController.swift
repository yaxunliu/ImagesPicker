//
//  AlbumListController.swift
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

//相簿列表项
public struct AlbumItem {
    //相簿名称
    var title:String?
    //相簿内的资源
    var fetchResult:PHFetchResult<PHAsset>
    
    init(title:String?,fetchResult:PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
    }
    
}

public struct AlbumSection {
    var header: String
    var albums: [AlbumItem]
}

extension AlbumSection: SectionModelType {
    public init(original: AlbumSection, items: [AlbumItem]) {
        self = original
        albums = items
    }
    
    public typealias Item = AlbumItem
    public typealias Identity = String
    public var items: [Item] {
        return albums
    }
    public var identity: String { return header }
    
}


public class AlbumListController: UIViewController {
    let bag = DisposeBag()
    var isPush: Bool = true
    var albums: BehaviorRelay<[AlbumSection]> = BehaviorRelay.init(value: [])
    var _maxSelectNum = 9
    var tableView: UITableView?
    
    lazy var navBar: NavBarView = {
        let nav = NavBarView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIApplication.shared.statusBarFrame.height + 44))
        nav.title = "照片"
        nav.rightTitle = "取消"
        nav.backButton.isHidden = true
        return nav
    }()
    
    var _selectImages: ([ImagePickerModel]) -> ()?
    
    
    public init(selectImages: @escaping ([ImagePickerModel]) -> (), maxSelectNum: Int) {
        _selectImages = selectImages
        _maxSelectNum = maxSelectNum
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.loadPhotoAlbums()
        observer()
    }
    
    func setupUI() {
        view.addSubview(navBar)
        tableView = UITableView.init()
        tableView?.rowHeight = 57
        tableView?.separatorStyle = .none
        tableView?.register(UINib.init(nibName: "AlbumCell", bundle: Bundle.init(for: AlbumListController.self)), forCellReuseIdentifier: "AlbumCell")
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        })
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    
}
extension AlbumListController {
    
    func observer() {
        self.navBar.rightButton.rx.controlEvent([.touchUpInside]).subscribe { [unowned self] _ in
            self.navigationController?.dismiss(animated: true, completion: nil)
            }.disposed(by: bag)
    }
    
    func loadPhotoAlbums() {
        //申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            // 列出所有系统的智能相册
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,subtype: .albumRegular,options: nil)
            let sysAblums = self.convertCollection(collection: smartAlbums)
            //列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            let cusAblums = self.convertCollection(collection: userCollections as! PHFetchResult<PHAssetCollection>)
            //异步加载表格数据,需要在主线程中调用reloadData() 方法
            DispatchQueue.main.async { [unowned self] in
                let items = sysAblums + cusAblums
                self.albums.accept([AlbumSection.init(header: "ablum", albums: items)])
                let imgPicker = ImagePickerController(selectImages: { [unowned self] (models) in
                    self.navigationController?.dismiss(animated: true, completion: {
                        self._selectImages(models)
                    })
                    }, maxNum: self._maxSelectNum)
                imgPicker.album = items[0]
                if self.isPush {
                    self.navigationController?.pushViewController(imgPicker, animated: false)
                    self.isPush = false
                }
            }
        })
        
        let dataSource = RxTableViewSectionedReloadDataSource<AlbumSection>.init(configureCell: { (ds, tb, index, model) -> UITableViewCell in
            let cell = tb.dequeueReusableCell(withIdentifier: "AlbumCell", for: index) as! AlbumCell
            cell.album = model
            return cell
        })
        
        tableView?.rx.itemSelected.subscribe { [unowned self] (event) in
            guard let index = event.element else { return }
            let album = self.albums.value[0].albums[index.row]
            
            let imgPicker = ImagePickerController(selectImages: { [unowned self] (models) in
                self.navigationController?.dismiss(animated: true, completion: {
                    self._selectImages(models)
                })
                }, maxNum: self._maxSelectNum)
            imgPicker.album = album
            self.navigationController?.pushViewController(imgPicker , animated: true)
            
            self.tableView?.deselectRow(at: index, animated: true)
            }.disposed(by: bag)
        
        
        albums.asObservable()
            .bind(to: tableView!.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}

extension AlbumListController {
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>) -> [AlbumItem] {
        var items:[AlbumItem] = []
        for i in 0..<collection.count{
            //获取出但前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                               ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType == %d",
                                                   PHAssetMediaType.image.rawValue)
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0{
                items.append(AlbumItem(title: c.localizedTitle,fetchResult: assetsFetchResult))
            }
        }
        return items
    }
}

