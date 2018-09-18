//
//  RegisterViewController.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/6/29.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit
import RxSwift
import YYText

public enum ControllerModel {
    case regist // 注册
    case reset  // 重置密码
}

enum RegisterImageResource: String {
    case checkBox = "checkbox_select"
    case uncheckbox = "checkbox_unselect"
}

extension RegisterImageResource {
    
    var image: UIImage {
        get {
            let scale = UIScreen.main.scale
            var imgName = ""
            switch scale {
            case 2.0:
                imgName = self.rawValue + "@2x.png"
            case 3.0:
                imgName = self.rawValue + "@3x.png"
            default:
                imgName = self.rawValue + "@2x.png"
            }
            let bundel = Bundle.init(for: RegisterViewController.self)
            guard let path = bundel.path(forResource: imgName, ofType: nil) else { return UIImage() }
            return UIImage.init(contentsOfFile: path)!
        }
    }
    
}


class RegisterViewController: UIViewController {
    
    // MARK: 1. 顶部导航栏
    fileprivate lazy var navBar: UIView = {
        let view = UIView.init()
        view.backgroundColor = ThemeColor.theme.color
        
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        
        closeButton.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
        })
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(closeButton)
        }
        
        return view
    }()
    
    fileprivate lazy var closeButton: UIButton = {
        let btn = UIButton.init()
        btn.setImage(LoginImageResource.close.image, for: .normal )
        btn.rx.tap.asObservable().subscribe({ [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        return btn
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    // MARK: 2.手机号码输入框
    fileprivate lazy var phoneNumTf: UITextField = {
        let tf = UITextField.init()
        tf.placeholder = "请输入手机号"
        tf.textColor = UIColor.getColor(hex: "c7c7cd")
        tf.rightView = self.authButton
        tf.rightViewMode = .always
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.keyboardType = .numberPad
        tf.setValue(UIColor.getColor(hex: "c7c7cd") , forKeyPath: "_placeholderLabel.textColor")
        return tf
    }()
    
    var authButton: AuthButton = {
        let button = AuthButton.init("获取验证码", 14, ThemeColor.sky_blue.color, 80)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 21)
        return button
    }()
    
    fileprivate var topSeperator: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.getColor(hex: "ecedf1")
        return view
    }()
    
    fileprivate var bottomSeperator: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.getColor(hex: "ecedf1")
        return view
    }()
    
    // MARK: 3.手机验证码输入框
    fileprivate lazy var userPwdTf: UITextField = {
        let tf = UITextField.init()
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.textColor = UIColor.getColor(hex: "c7c7cd")
        tf.isSecureTextEntry = false
        tf.placeholder = "请输入五位手机验证码"
        tf.rightViewMode = .never
        tf.setValue(UIColor.getColor(hex: "c7c7cd"), forKeyPath: "_placeholderLabel.textColor")
        return tf
    }()
    
    // MARK: 4.下一步按钮
    fileprivate lazy var nextStep: UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIColor.getImage(color: ThemeColor.theme.color), for: .disabled)
        button.setBackgroundImage(UIColor.getImage(color: ThemeColor.sky_blue.color), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitle("下一步", for: .normal)
        return button
    }()
    
    // MARK: 5.选中按钮
    fileprivate lazy var checkBox: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(RegisterImageResource.checkBox.image , for: .selected)
        button.setImage(RegisterImageResource.uncheckbox.image, for: .normal)
        button.isSelected = true
        return button
    }()
    
    fileprivate lazy var protocolLabel: YYLabel = {
        let label = YYLabel.init()
        label.textVerticalAlignment = .center
        let str = "已阅读并同意慧选股服务协议及风险提示"
        label.preferredMaxLayoutWidth = 400
        let attr = NSMutableAttributedString.init(string: str)
        attr.yy_font = UIFont.systemFont(ofSize: 13)
        attr.yy_color = .black
        let serviceRange = NSString.init(string: str).range(of: "慧选股服务协议及风险提示")
        
        // MARK: TODO 风险协议跳转暂时还未处理
        attr.yy_setTextHighlight(serviceRange, color: ThemeColor.sky_blue.color, backgroundColor: ThemeColor.theme.color) { (_, _, _, _) in
            
        }
        label.attributedText = attr
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: 6. viewModel相关常量和变量
    var _model: ControllerModel = ControllerModel.regist
    var viewModel: RegisterViewModel!
    let bag = DisposeBag()
    var _fromLogin: Bool = true
    
    /// 可以用来注册或者重置密码
    init(_ model: ControllerModel, fromLogin: Bool = true) {
        _model = model
        _fromLogin = fromLogin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.userPwdTf.resignFirstResponder()
        self.phoneNumTf.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observer()
    }
}

extension RegisterViewController {
    func observer() {
        // 1. 创建viewModel实例对象
        let obj = self.checkBox.rx.tap.asObservable().map { [weak self] _ -> Bool in
            guard let `self` = self else { return false }
            self.checkBox.isSelected = !self.checkBox.isSelected
            return self.checkBox.isSelected
        }
                
        viewModel = RegisterViewModel.init(phoneNumSingal: self.phoneNumTf.rx.text.asObservable(),
                                           authcodeSingal: self.userPwdTf.rx.text.asObservable(),
                                           getAuthSingal: self.authButton.getAuthSingal,
                                           nextTapSingal: self.nextStep.rx.tap.asObservable(),
                                           nextStepEnableSingal: self.nextStep.rx.isEnabled,
                                           authCountDownSingal: self.authButton.rx.countDown,
                                           authButtonStatus: self.authButton.rx.authStatus,
                                           riskProtocolSingal: obj,
                                           authApi: _model == .regist ? .regist : .forget)
        
        // 2. 监听验证码通过状态
        viewModel.authCodePass.subscribe { (event) in
            guard let isPass = event.element else { return }
            if !isPass { return }
            
            self.phoneNumTf.rightViewMode = .never
            self.phoneNumTf.placeholder = "请输入密码"
            self.phoneNumTf.isSecureTextEntry = true
            self.phoneNumTf.keyboardType = .default
            self.userPwdTf.placeholder = "请确认密码"
            self.userPwdTf.isSecureTextEntry = true
            
            self.phoneNumTf.resignFirstResponder()
            self.userPwdTf.resignFirstResponder()
            self.phoneNumTf.text = nil
            self.userPwdTf.text = nil
            
            // 隐藏服务协议
            self.protocolLabel.removeFromSuperview()
            self.checkBox.removeFromSuperview()
            self.nextStep.setTitle("完成", for: .normal)
            self.nextStep.isEnabled = false
            }.disposed(by: bag)
        
        // 3.监听获取验证码的状态
        viewModel.authCodeStatus.subscribe { (event) in
            guard let status = event.element else { return }
            switch status {
            case .sendding:
                self.showait(message: "正在发送验证码")
                break
            case .succes:
                self.showait(message: "发送成功")
                self.hidden()
                break
            case .failure:
                self.showError(message: "发送验证码失败")
                break
            default :
                break
            }
        }.disposed(by: bag)
        
        // 4.监听其他状态信息
        viewModel.currentStatus.subscribe { [weak self] event in
            guard let `self` = self else { return }
            guard let status = event.element else { return }
            switch status {
                case .none:
                    return
                case .registting:
                    self.showait(message: "正在注册")
                    break
                case .resetting:
                    self.showait(message: "正在重置密码")
                    break
                case .error(let err):
                    self.showError(message: err)
                    break
                case .resetOk:
                    self.showSuccess(message: "密码重置成功")
                    self.dismiss(animated: true, completion: nil)
                    break
                case .noError:
                    self.showSuccess(message: "注册成功")
                    self.dismiss(animated: true, completion: nil)
                    break
                }
        }.disposed(by: bag)
    
    }
    
}

extension RegisterViewController {
    func setupUI() {
        view.backgroundColor = .white
        let title = self._model == .regist ? "注册" : "重置密码"
        self.titleLabel.text = title
        // 1. navBar
        view.addSubview(self.navBar)
        let navH = UIScreen.adaptor(64, 64, 64, 88, 64)
        navBar.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navH)
        }
        // 2. 输入框
        view.addSubview(phoneNumTf)
        view.addSubview(userPwdTf)
        view.addSubview(topSeperator)
        view.addSubview(bottomSeperator)
        
        let marginTop = UIScreen.rateAdaptorHeight(31)
        let seperatorMarginTop = UIScreen.rateAdaptorHeight(16.5)
        phoneNumTf.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom).offset(marginTop)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(17)
        }
        
        topSeperator.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(1)
            make.top.equalTo(phoneNumTf.snp.bottom).offset(seperatorMarginTop)
        }
        
        userPwdTf.snp.makeConstraints { (make) in
            make.height.left.right.equalTo(phoneNumTf)
            make.top.equalTo(topSeperator.snp.bottom).offset(seperatorMarginTop)
        }
        
        bottomSeperator.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(topSeperator)
            make.top.equalTo(userPwdTf.snp.bottom).offset(seperatorMarginTop)
        }
        
        // 3. 下一步
        view.addSubview(nextStep)
        let nextHieght = UIScreen.rateAdaptorHeight(40)
        nextStep.snp.makeConstraints { (make) in
            make.left.right.equalTo(bottomSeperator)
            make.height.equalTo(nextHieght)
            make.top.equalTo(bottomSeperator.snp.bottom).offset(nextHieght * 0.5)
        }
        
        if self._model == .reset { return }
        // 4.富文本
        view.addSubview(checkBox)
        view.addSubview(protocolLabel)
        
        checkBox.snp.makeConstraints { (make) in
            make.left.equalTo(nextStep)
            make.top.equalTo(nextStep.snp.bottom).offset(nextHieght * 0.5)
        }
        
        protocolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(checkBox.snp.right).offset(8)
            make.centerY.equalTo(checkBox).offset(2)
        }
    }
}

