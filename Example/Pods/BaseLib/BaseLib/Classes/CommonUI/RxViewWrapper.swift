//
//  RxView-Extension.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/7/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public class ActivityButton: UIView {
    
    private(set) var tap: Observable<Void>?
    
    fileprivate lazy var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        return activity
    }()
    
    fileprivate lazy var button: UIButton = {
        let btn = UIButton.init(type: .system)
        return btn
    }()
    public init(frame: CGRect, normalColor: UIColor?, disEnableColor: UIColor?, fontSize: CGFloat, normalTitle: String?, didEnableTitle: String?) {
        super.init(frame: frame)
        setupUI()
        button.setTitleColor(normalColor, for: .normal)
        button.setTitleColor(disEnableColor, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.setTitle(normalTitle, for: .normal)
        if didEnableTitle != nil {
            button.setTitle(didEnableTitle, for: .disabled)
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(activity)
        addSubview(button)
        self.tap = button.rx.controlEvent([.touchUpInside]).asObservable()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        activity.center = self.center
        button.frame = self.bounds
    }
    
}

public enum ActivityButtonStatus {
    case normal
    case animation
    case unable
}

extension Reactive where Base == ActivityButton {
    
    public var status: Binder<ActivityButtonStatus?> {
        return Binder(self.base) { view, status in
            guard let sts = status else { return }
            switch sts {
            case .normal:
                print("normal")
                view.activity.stopAnimating()
                view.button.isHidden = false
                view.button.isEnabled = true
                return
            case .animation:
                print("animation")
                view.activity.startAnimating()
                view.button.isHidden = true
                view.button.isEnabled = false
                return
            case .unable:
                print("unable")
                view.activity.stopAnimating()
                view.button.isHidden = false
                view.button.isEnabled = false
                return
            }
        }
    }
}



// MARK:
public enum AuthCodeButtonType {
    case normal   // 普通   -> 获取验证码
    case sendding // 发送验证码
    case succes   // 发送验证码成功
    case failure  // 发送验证码失败
    case waitting // 等待输入   -> 53s
    case timeout  // 超时   -> 重新发送
}


@IBDesignable public class AuthButton: UIView {
    
    let bag = DisposeBag()
    
    var authTap: Observable<Void>?
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    var contentView: UIView?
    
    @IBInspectable var fontSize: CGFloat = 10 {
        didSet {
            if contentView != nil {
                self.button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                self.countDownLabel.font = UIFont.systemFont(ofSize: fontSize)
            }
        }
    }
    
    @IBInspectable var style: UIColor = .white {
        didSet {
            if contentView != nil {
                setColor(style)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        contentView = loadFromXib()
        contentView?.frame = self.bounds
        addSubview(contentView!)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.button.layer.masksToBounds = true
        self.button.layer.cornerRadius = self.frame.height * 0.5
    }
    
    public func loadFromXib() -> UIView? {
        let bundle = Bundle(for: AuthButton.self)
        let nib = UINib.init(nibName: "AuthButton", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView
    }
    
    public func setColor(_ style: UIColor) {
        self.button.layer.borderColor = style.cgColor
        self.countDownLabel.textColor = style
        self.activityView.color = style
        self.button.layer.borderWidth = 1
        self.button.setTitleColor(style, for: .normal)
        self.button.setTitle("获取验证码", for: .normal)
    }
}

extension Reactive where Base == AuthButton {
    
    public var countDown: Binder<String?> {
        return Binder(self.base) { view, str in
            guard let count = str else { return }
            view.countDownLabel.text = count
        }
    }
    
    public var authStatus: Binder<AuthCodeButtonType> {
        return Binder(self.base) { view, type in
            
            switch type {
            case .normal:
                view.button.setTitle("获取验证码", for: .normal)
                view.button.isHidden = false
                view.activityView.isHidden = true
                view.countDownLabel.isHidden = true
                break
            case .sendding:
                view.button.isHidden = true
                view.activityView.isHidden = false
                view.countDownLabel.isHidden = true
                break
            case .succes:
                view.button.isHidden = true
                view.activityView.isHidden = true
                view.countDownLabel.isHidden = false
                break
            case .failure:
                view.button.isHidden = false
                view.button.setTitle("重新获取", for: .normal)
                view.activityView.isHidden = true
                view.countDownLabel.isHidden = true
                break
            case .waitting:
                view.button.isHidden = true
                view.activityView.isHidden = true
                view.countDownLabel.isHidden = false
                break
            case .timeout:
                view.button.setTitle("重新发送", for: .normal)
                view.button.isHidden = false
                view.activityView.isHidden = true
                view.countDownLabel.isHidden = true
                break
            }
            
            
        }
    }
}




