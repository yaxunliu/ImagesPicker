//
//  LoginViewController.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/5/14.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import YYText
import SnapKit


enum LoginImageResource: String {
    case close =            "ic_close"
    case seperatorBgView =  "seperatorimage"
    case wechat =           "img_weixin"
    case loginBgImage =     "bg_registered"
    case showPwd =          "ic_invisible"
}

extension LoginImageResource {
    
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

class LoginViewController: UIViewController {
    // MARK: 1. 背景
    fileprivate lazy var bgImg: UIImageView = {
        let imgView = UIImageView()
        imgView.image = LoginImageResource.loginBgImage.image
        return imgView
    }()

    
    // MARK: 1. 关闭按钮
    fileprivate lazy var closeButton: UIButton = {
        let btn = UIButton.init()
        btn.setImage(LoginImageResource.close.image, for: .normal )
        return btn
    }()
    
    // MARK: 2. 标题
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.text = "慧选股"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: UIScreen.rateAdaptorHeight(40))
        return label
    }()
    
    // MARK: 3. 分组视图
    fileprivate lazy var segmentView: UIView = {
        let view = UIView()
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints({ (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        })
        
        view.addSubview(authButton)
        authButton.snp.makeConstraints({ (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        })
        
        view.addSubview(accountButton)
        accountButton.snp.makeConstraints({ (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        })

        return view
    }()
    
    fileprivate lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        return view
    }()
    
    fileprivate lazy var accountButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("账号登录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    fileprivate lazy var authButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("验证码登录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    // MARK: 4. 用户名 密码
    fileprivate lazy var userNameTf: UITextField = {
        let tf = UITextField.init()
        tf.placeholder = "输入用户名"
        tf.textColor = .white
        tf.rightView = clearButton
        tf.rightViewMode = .always
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        tf.setValue(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6) , forKeyPath: "_placeholderLabel.textColor")
        return tf
    }()
    
    fileprivate lazy var clearButton: UIButton = {
        let clearButton = UIButton.init(type: .custom)
        clearButton.setImage(LoginImageResource.close.image, for: .normal)
        clearButton.contentMode = .scaleToFill
        clearButton.rx.tap.asControlEvent().subscribe({ _ in
            self.userNameTf.text = nil
        }).disposed(by: self.bag)
        clearButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        return clearButton
    }()
    
    fileprivate lazy var loginAuthcodeButton: AuthButton = {
        let button = AuthButton("获取验证码", 9, .white)
        button.frame = CGRect(x: 0, y: 0, width: 62, height: 16)
        return button
    }()
    
    fileprivate lazy var userPwdTf: UITextField = {
        let tf = UITextField.init()
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.isSecureTextEntry = true
        tf.placeholder = "输入密码"
        tf.rightView = self.loginAuthcodeButton
        tf.rightViewMode = .never        
        tf.setValue(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6) , forKeyPath: "_placeholderLabel.textColor")
        
        let showButton = UIButton.init(type: .custom)
        showButton.setImage(LoginImageResource.showPwd.image, for: .normal)
        showButton.contentMode = .scaleToFill
        showButton.rx.controlEvent([.touchDown]) .subscribe({ _ in
            tf.isSecureTextEntry = false
        }).disposed(by: self.bag)
        
        showButton.rx.controlEvent([.touchUpInside]) .subscribe({ _ in
            tf.isSecureTextEntry = true
        }).disposed(by: self.bag)
        
        showButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        tf.rightView = showButton
        tf.rightViewMode = .always
        
        return tf
    }()
    
    fileprivate lazy var topSeperator: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var bottomSeperator: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    
    
    // MARK: 5.登录按钮
    fileprivate lazy var loginButton: UIButton = {
        let button = UIButton.init()
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIColor.getImage(color: UIColor.getColor(hex: "368affCC")!), for: .normal)
        button.setBackgroundImage(UIColor.getImage(color: UIColor.getColor(hex: "707070CC")!), for: .disabled)
        button.layer.cornerRadius = UIScreen.rateAdaptorHeight(38)
        return button
    }()
    
    // 注册 忘记密码
    fileprivate lazy var register: UIButton = {
        let button = UIButton.init()
        button.setTitle("注册", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    fileprivate lazy var forgetButton: UIButton = {
        let button = UIButton.init()
        button.setTitle("忘记密码", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: 6. 分割线
    let seperatorimgView: UIImageView = {
        let img = UIImageView.init()
        img.image = LoginImageResource.seperatorBgView.image
        return img
    }()
    
    // MARK: 7. 微信登录按钮
    fileprivate lazy var wechatButton: UIButton = {
        let button = UIButton.init()
        button.setImage(LoginImageResource.wechat.image , for: .normal)
        return button
    }()
    
    // MARK: 8. 服务协议
    fileprivate lazy var protocolLabel: YYLabel = {
        let label = YYLabel.init()
        let str = "已阅读并同意慧选股服务协议及风险协议"
        let attr = NSMutableAttributedString.init(string: str)
        attr.yy_font = UIFont.systemFont(ofSize: 10)
        attr.yy_color = .white
        let serviceRange = NSString.init(string: str).range(of: "慧选股服务协议及风险协议")
        
        // MARK: TODO 风险协议跳转暂时还未处理
        attr.yy_setTextHighlight(serviceRange, color: ThemeColor.sky_blue.color, backgroundColor: ThemeColor.theme.color) { (_, _, _, _) in
            
        }
        label.attributedText = attr
        label.textAlignment = .center
        return label
    }()
    
    
    var handleBlock: ((Bool)->())?
    
    // MARK: viewModel相关常亮和变量
    private var bag: DisposeBag = DisposeBag()
    private var _viewModel: LoginViewModel!
    private var _loginTypeSingal : BehaviorRelay<LoginType> = BehaviorRelay.init(value: .account)
    
    init(_ handle: ((Bool)->())?) {
        handleBlock = handle
        super.init(nibName: nil, bundle: nil)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTf.text = Keychain.get(.phone)
        setupUI()
        observer()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirst()
    }
    
    func resignFirst() {
        userNameTf.resignFirstResponder()
        userPwdTf.resignFirstResponder()
    }
    
}

extension LoginViewController {
    
    func setupUI() {
        
        // 1.添加背景视图
        view.addSubview(bgImg)
        bgImg.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // 2.关闭按钮
        view.addSubview(closeButton)
        let offset = UIScreen.adaptor(25, 25, 25, 50, 25)
        closeButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(offset)
            make.top.equalToSuperview().offset(offset)
        }
        
        // 3.标题
        view.addSubview(titleLabel)
        let titleOffsetY = UIScreen.rateAdaptorHeight(128)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(titleOffsetY)
        }
        
        // 4.segment
        view.addSubview(segmentView)
        let segmentOffsetY = UIScreen.rateAdaptorHeight(49)
        let segmentWidth = UIScreen.rateAdaptorWidth(188)
        let segmentHeight = UIScreen.rateAdaptorHeight(30)
        segmentView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(segmentOffsetY)
            make.width.equalTo(segmentWidth)
            make.height.equalTo(segmentHeight)
        }
        segmentView.layer.cornerRadius = segmentHeight * 0.5
        segmentView.layer.borderColor = UIColor.white.cgColor
        segmentView.layer.borderWidth = 1
        indicatorView.layer.cornerRadius = segmentHeight * 0.5
        
        // 5. 输入框
        view.addSubview(userNameTf)
        view.addSubview(topSeperator)
        view.addSubview(userPwdTf)
        view.addSubview(bottomSeperator)
        
        let userOffsetY = UIScreen.rateAdaptorHeight(45)
        let tfWidth = UIScreen.rateAdaptorWidth(250)
        let tfHeight = UIScreen.rateAdaptorHeight(16)
        let inputSeperatorOffsetY = UIScreen.rateAdaptorHeight(11)
        userNameTf.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentView.snp.bottom).offset(userOffsetY)
            make.width.equalTo(tfWidth)
            make.height.equalTo(tfHeight)
        }
        
        topSeperator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(userNameTf.snp.bottom).offset(inputSeperatorOffsetY)
            make.height.equalTo(1)
            make.width.equalTo(tfWidth + 15)
        }
        
        let pwdOffsetY = UIScreen.rateAdaptorHeight(28)
        userPwdTf.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topSeperator.snp.bottom).offset(pwdOffsetY)
            make.width.equalTo(tfWidth)
            make.height.equalTo(tfHeight)
        }
        bottomSeperator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(userPwdTf.snp.bottom).offset(inputSeperatorOffsetY)
            make.height.equalTo(1)
            make.width.equalTo(tfWidth + 15)
        }
        
        // 6.登录按钮
        let loginHeight = UIScreen.rateAdaptorHeight(38)
        let loginOffsetY = UIScreen.rateAdaptorHeight(35)
        
        loginButton.layer.cornerRadius = loginHeight * 0.5
        loginButton.layer.masksToBounds = true
        view.addSubview(loginButton)
        view.addSubview(register)
        view.addSubview(forgetButton)
        
        loginButton.snp.makeConstraints { (make) in
            make.right.left.equalTo(bottomSeperator)
            make.height.equalTo(loginHeight)
            make.top.equalTo(bottomSeperator.snp.bottom).offset(loginOffsetY)
        }
        let registOffsetY = UIScreen.rateAdaptorHeight(8)
        register.snp.makeConstraints { (make) in
            make.left.equalTo(loginButton)
            make.top.equalTo(loginButton.snp.bottom).offset(registOffsetY)
        }
        
        forgetButton.snp.makeConstraints { (make) in
            make.right.equalTo(loginButton)
            make.top.equalTo(loginButton.snp.bottom).offset(registOffsetY)
        }
        
        // 7.分割线
        view.addSubview(seperatorimgView)
        let seperatorOffsetY = UIScreen.rateAdaptorHeight(53)
        seperatorimgView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom).offset(seperatorOffsetY)
        }
        
        // 8.微信登录
        view.addSubview(wechatButton)
        let wechatOffsetY = UIScreen.rateAdaptorHeight(28)
        wechatButton.snp.makeConstraints { (make) in
            make.top.equalTo(seperatorimgView.snp.bottom).offset(wechatOffsetY)
            make.centerX.equalToSuperview()
        }
        
        // 9.提示
        
        view.addSubview(protocolLabel)
        let marginBottom = UIScreen.rateAdaptorHeight(17)
        let margin = UIScreen.adaptor(marginBottom, marginBottom, marginBottom, marginBottom + 34, marginBottom)
        protocolLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-margin)
        }
        
    }
    
    
}

// MARK: - UI控制vartension LoginViewController {
extension LoginViewController {
    
    func observer() {
        
        // 1. 账号，验证码登录切换
        self.accountButton.rx.tap.asControlEvent().map{ LoginType.account }.bind(to: _loginTypeSingal).disposed(by: bag)
        self.authButton.rx.tap.asControlEvent().map{ LoginType.authCode }.bind(to: _loginTypeSingal).disposed(by: bag)

        // 2.绑定viewModel
        let loginSingal = loginButton.rx.controlEvent([.touchUpInside]).asObservable()
        let getAuthSingal = loginAuthcodeButton.getAuthSingal
        let userName = userNameTf.rx.text.asObservable()
        let authPwd = userPwdTf.rx.text.asObservable()
        
        _viewModel = LoginViewModel.init(authInput: authPwd,
                                         phoneInput: userName,
                                         getAuthTap: getAuthSingal!,
                                         loginSingal: loginSingal,
                                         loginTypeSingal: _loginTypeSingal,
                                         loginEnable: self.loginButton.rx.isEnabled,
                                         authCountDown: self.loginAuthcodeButton.rx.countDown,
                                         authButtonStatus: self.loginAuthcodeButton.rx.authStatus,
                                         authApi: .login)
        
        _viewModel.loginErrInfo.subscribe { event in
            guard let err = event.element else { return }
            switch err {
            case .success:
                self.showSuccess(message: "登录成功")
                Keychain.save(.phone, value: self.userNameTf.text!)
                if self.handleBlock != nil {
                    self.handleBlock!(true)
                }
                self.dismiss(animated: true, completion: nil)
                break
            case .failure(let error):
                self.showError(message: error)
                break
            case .logining:
                self.showait(message: nil)
                self.resignFirst()
                break
            case .none:
                break
            }
            
        }.disposed(by: bag)
        
        // 3.监听获取验证码的状态
        _viewModel.authCodeStatus.subscribe { (event) in
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
        
        
        // 4.监听登录方式切换
        var _isAnimation = false
        _loginTypeSingal.subscribe { [weak self] (event) in
            guard let type = event.element else { return }
            var placeHolder = "请输入密码"
            var sercureText = false
            var rightView: UIView? = self?.loginAuthcodeButton
            var show = true
            if type == .account {
                sercureText = true
                rightView = self?.clearButton
                self?.indicatorView.snp.remakeConstraints({ (make) in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.5)
                })
            } else {
                placeHolder = "请输入验证码"
                show = false
                self?.indicatorView.snp.remakeConstraints({ (make) in
                    make.right.top.bottom.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.5)
                })
            }
            if _isAnimation == false {
                _isAnimation = true
                return
            }
            UIView.animate(withDuration: 0.5, animations: {
                self?.view.layoutIfNeeded()
            }, completion: { _ in
                self?.userPwdTf.placeholder = placeHolder
                self?.userPwdTf.isSecureTextEntry = sercureText
                self?.userNameTf.rightView = rightView
                self?.userNameTf.rightViewMode = .always
                self?.userPwdTf.rightViewMode = show ? .always : .never
            })
        }.disposed(by: bag)
        
        // 5. 微信登录 忘记密码 注册 关闭
        /// TODO: 微信登录待处理
        self.wechatButton.rx.tap.asObservable().subscribe { _ in
            
        }.disposed(by: bag)
        
        self.forgetButton.rx.tap.asObservable().subscribe { _ in
            self.present(RegisterViewController.init(.reset), animated: true, completion: nil)
        }.disposed(by: bag)
        
        self.register.rx.tap.asObservable().subscribe { _ in
            self.present(RegisterViewController.init(.regist), animated: true, completion: nil)
        }.disposed(by: bag)
        
        self.closeButton.rx.tap.asObservable().subscribe { _ in
            if self.handleBlock != nil {
                self.handleBlock!(false)
            }
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)
        
        
    }

}


