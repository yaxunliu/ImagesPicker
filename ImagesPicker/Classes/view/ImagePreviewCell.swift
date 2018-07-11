//
//  ImagePreviewCell.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ImagePreviewCell: UICollectionViewCell {

    var bag: DisposeBag?
    var model: ImagePickerModel? {
        didSet {
            bag = DisposeBag()
            scrollView.setZoomScale(1.0, animated: false)
            resizeSubviews()
        }
    }
    var _contains = UIView.init()
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var tap: UITapGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.backgroundColor = .black
        /// 单击
        let _tap = UITapGestureRecognizer.init()
        self.addGestureRecognizer(_tap)
        /// 双击
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap(tap:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        _tap.require(toFail: doubleTap)
        self.tap = _tap
        contentView.addSubview(scrollView)
        scrollView.addSubview(_contains)
        _contains.addSubview(previewImageView)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    func resizeSubviews() {
        guard let image = previewImageView.image else { return }
        // 1.contains 的高度
        let imageHeight = self.frame.width / (image.size.width / image.size.height)
        _contains.frame.size = CGSize(width: self.frame.width, height: imageHeight)
        // 2.conrains 的y值
        var y: CGFloat = 0
        if imageHeight < self.frame.height { // 图片内部
            y = (self.frame.height - imageHeight) / 2.0
        }
        _contains.frame.origin = CGPoint(x: 0, y: y)
        previewImageView.frame = _contains.bounds
        scrollView.contentSize = CGSize(width: self.frame.width, height: _contains.frame.height)
    }
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.bouncesZoom = true
        scroll.maximumZoomScale = 2.5
        scroll.minimumZoomScale = 1.0
        scroll.isMultipleTouchEnabled = true
        scroll.delegate = self
        scroll.scrollsToTop = false
        scroll.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scroll.delaysContentTouches = false
        scroll.canCancelContentTouches = true
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
}

extension ImagePreviewCell {
    @objc func doubleTap (tap: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.contentInset = .zero
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint = tap.location(in: self.previewImageView)
            let zoomScale = scrollView.maximumZoomScale
            let xSize = self.frame.width / zoomScale
            let ySize = self.frame.height / zoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - xSize / 2, y: touchPoint.y - ySize / 2, width: xSize, height: ySize)  , animated: true)
        }
    }
}

extension ImagePreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _contains
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let offsetX = scrollView.frame.width > scrollView.contentSize.width ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = scrollView.frame.height > scrollView.contentSize.height ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0.0
        self._contains.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
}
