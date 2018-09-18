//
//  YYText-Extension.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/7/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YYText

public class PlaceTextView: UITextView {
    fileprivate var _placeLabel = UILabel()
    fileprivate var _bag = DisposeBag()
    public func placeholderText(_ str: String) -> PlaceTextView {
        self._placeLabel.text = str
        return self
    }
    
    public func placeholderTextColor(_ color: UIColor) -> PlaceTextView {
        self._placeLabel.textColor = color
        return self
    }
    
    public func placeholderFont(_ font: UIFont) -> PlaceTextView {
        self._placeLabel.font = font
        return self
    }
    
    public init(frame: CGRect,
                left: CGFloat,
                top: CGFloat,
                isAlignCenter: Bool = false) {
        super.init(frame: frame, textContainer: nil)
        addSubview(_placeLabel)
        
        if isAlignCenter {
            _placeLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(5)
                make.centerY.equalToSuperview()
            }
        } else {
            _placeLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(left)
                make.top.equalToSuperview().offset(top)
            }
        }
        
        self.rx.text.map { (str) -> Bool in
            if str == nil { return true }
            else if str!.count > 0 {
                return true
            }
            return false
            }.bind(to: self._placeLabel.rx.isHidden).disposed(by: _bag)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
}
 
public class RichTextLabel: YYLabel {
    
    fileprivate var _fontSize: CGFloat = 0
    fileprivate var _normalColor: UIColor = .black
    fileprivate var _lineSpace: CGFloat = 9.0
    fileprivate var _prefreWidth: CGFloat = 0.0
    fileprivate var _tapHightActions: [NSRange : String] = [:]
    
    /// 点击了label
    public var tapLabel: PublishSubject<Void> = PublishSubject.init()
    /// 点击了高亮部分
    public var tapHightAction: PublishSubject<String> = PublishSubject.init()
    
    public init(fontSize: CGFloat,
         lineSpace: CGFloat,
         normalColor: UIColor,
         _ preferwidth: CGFloat = UIScreen.main.bounds.width - 30,
         isObserverTap: Bool) {
        
        super.init(frame: .zero)
        _lineSpace = lineSpace
        _fontSize = fontSize
        _normalColor = normalColor
        _prefreWidth = preferwidth
        self.preferredMaxLayoutWidth = _prefreWidth
        if isObserverTap {
            self.textTapAction = { view, text, range, rect in
                // 延迟0.5秒去处理这个时间
                self.perform(#selector(self.handleTap), with: nil, afterDelay: 0.5)
            }
        }
        
        self.highlightTapAction = { view, text, range, rect in
            guard let action = self._tapHightActions[range] else { return }
            self.tapHightAction.onNext(action)
            if !isObserverTap { return }
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.handleTap), object: nil)
        }
        
    }
    
    @objc func handleTap() {
        self.tapLabel.onNext(())
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


public extension RichTextLabel {
    
    /*
     *  tapRanges: 需要特殊处理的点击
     */
    public func setAttrStr(_ withText: String, tapCustomRanges: [NSRange:String]? = nil) {
        let attrM = NSMutableAttributedString.init(string: withText)
        attrM.yy_color = self._normalColor
        attrM.yy_font = UIFont.systemFont(ofSize: _fontSize)
        
        // 1. 昵称点击
        if tapCustomRanges != nil {
            for tapRange in tapCustomRanges! {
                self._tapHightActions.updateValue(tapRange.value, forKey: tapRange.key)
                attrM.yy_setTextHighlight(tapRange.key, color: ThemeColor.sky_blue.color, backgroundColor: ThemeColor.font_less_black.color, userInfo: nil, tapAction: nil, longPressAction: nil)
            }
        }
        
        // 2. 匹配股票
        do {
            let regex = try NSRegularExpression.init(pattern: "\\$[\\u4e00-\\u9fa5]{1,}\\([s,S][z,Z,h,H]\\d{6}\\)\\$", options: NSRegularExpression.Options.caseInsensitive)
            var matchs = regex.matches(in: withText, options: .reportCompletion, range: NSMakeRange(0, withText.count))
            matchs.reverse()
            for stock in matchs {
                let str = NSString.init(string: withText).substring(with: stock.range)
                let splitStr = str.contains("s") ? "s" : "S"
                let subStrs = str.split(separator: "(")
                guard var name = subStrs.first else { continue }
                guard let symbol = subStrs.last else { continue }
                guard let index = name.index(of: "$") else { continue }
                guard let symbolEndIndex = symbol.index(of: ")") else { continue }
                guard let symbolStartIndex = symbol.index(of: Character.init(splitStr)) else { continue }
                name.remove(at: index)
                let symbolStr = symbol[symbolStartIndex..<symbolEndIndex]
                self._tapHightActions.updateValue(BaseRouterURLBuilder.stockDetail(name: String(name), symbol: String(symbolStr)).routerURL, forKey: stock.range)
                attrM.yy_setTextHighlight(stock.range, color: ThemeColor.sky_blue.color, backgroundColor: ThemeColor.font_less_black.color, userInfo: nil, tapAction:nil)
            }
        } catch let error {
            print("error", error)
        }
        
        
        // 3. 匹配emoji
        do {
            let regex = try NSRegularExpression.init(pattern: "\\[[^\\[^\\]]+\\]", options: NSRegularExpression.Options.caseInsensitive)
            var matchs = regex.matches(in: withText, options: .reportCompletion, range: NSMakeRange(0, withText.count))
            matchs.reverse()
            for emoji in matchs {
                let emojiName = NSString.init(string: withText).substring(with: emoji.range)
                guard let img = emojiParseDict[emojiName] else { continue }
                attrM.replaceCharacters(in: emoji.range, with: NSAttributedString.yy_attachmentString(withEmojiImage: img, fontSize: self._fontSize)!)
            }
        } catch let error {
            print("error", error)
        }
        
        let modifier = YYTextLinePositionSimpleModifier.init()
        modifier.fixedLineHeight = self._lineSpace + self._fontSize
        let contains = YYTextContainer.init()
        contains.size = CGSize(width: self._prefreWidth, height: CGFloat.greatestFiniteMagnitude)
        contains.linePositionModifier = modifier
        let layout = YYTextLayout.init(container: contains, text: attrM)
        let parser = YYTextSimpleEmoticonParser.init()
        parser.emoticonMapper = emojiParseDict
        self.numberOfLines = 0
        self.textLayout = layout!
        
        guard let size = layout?.textBoundingSize else { return }
        self.frame.size = size
    }
    
}
