//
//  AuthCodeViewModel.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/7/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Moya
import ObjectMapper

public struct AuthCodoResult: Mappable {
    public init?(map: Map) {
    }
    var code: Int?
    var data: String?
    var err_info: String?
    
    mutating public func mapping(map: Map) {
        code <- map["code"]
        data <- map["data"]
        err_info <- map["err_info"]
    }
}


public enum ResultCode: Int {
    case ERROR = -1
    case SUCCESS = 1
}

public enum AuthCodeError {
    case none       // 没有错误
    case success    // 获取验证码成功
    case failure(error: String)   // 失败
}


public class AuthCodeViewModel {
    /// 验证码
    var authStr = ""
    /// 验证码后台发送的手机验证码加密后的(用来验证输入的验证码是否正确)
    var vaildCode: String?
    /// 验证码输入
    var authCode: Observable<String?>
    /// 获取验证码按钮点击
    var authTap: Observable<Void>
    /// 手机号
    var currentPhoneStr = ""
    /// 获取验证码的手机号
    var getAuthCodePhone = ""
    /// 手机号输入
    var phoneNum: Observable<String?>
    /// 验证码类型
    let authType: AuthCodeType?
    /// 验证码和账号是否输合法(可以用来判断下一步按钮是否可以点击)
    let authAcountIsVaild = BehaviorRelay.init(value: false)
    /// 验证码是否通过验证
    let authCodePass = BehaviorRelay.init(value: false)
    /// 获取验证码失败的信息
    let authError = BehaviorRelay.init(value: AuthCodeError.none)
    /// 倒计时定时器(发送验证码逻辑)
    /// 验证码按钮的状态
    var authCodeStatus = BehaviorRelay.init(value: AuthCodeButtonType.normal)
    /// 倒计时定时器
    var timerBag = BehaviorRelay.init(value: true)
    /// 倒数字符串
    var countDownStr = BehaviorRelay.init(value: "")
    var dispose: Disposable?
    var provider = MoyaProvider<BaseNetworkApi>.init()
    let bag = DisposeBag()
    
    init(input: (authInput: Observable<String?>, phoneInput: Observable<String?>, getAuthTap: Observable<Void>, authCountDown: Binder<String?>, authButtonStatus: Binder<AuthCodeButtonType>),
         authApi: AuthCodeType
        ) {
        authCode = input.authInput
        authTap = input.getAuthTap
        phoneNum = input.phoneInput
        authType = authApi
        countDownStr.asDriver().drive(input.authCountDown).disposed(by: bag)
        authCodeStatus.asDriver().drive(input.authButtonStatus).disposed(by: bag)
        startObserver()
    }
    
    
    func startObserver() {
        /// 输入手机号 -> 验证手机号长度
        phoneNum.subscribe { [unowned self] (phoneEvent) in
            let phoneStr = phoneEvent.element ?? ""
            guard let phone = phoneStr else { return }
            self.currentPhoneStr = phone
            self.authAcountIsVaild.accept(phone.isMobile && self.authStr.count >= 5)
            }.disposed(by: bag)
        /// 输入验证码 -> 验证长度 -> 验证是否正确
        authCode.subscribe { [unowned self] (authEvent) in
            let authStr = authEvent.element ?? ""
            guard let auth = authStr else { return }
            self.authStr = auth
            self.authAcountIsVaild.accept(self.currentPhoneStr.isMobile && self.authStr.count >= 5)
            }.disposed(by: bag)
        authTap.subscribe { [unowned self] (event) in
            self.getAuthCode()
            }.disposed(by: bag)
    }
    
}

public extension AuthCodeViewModel {
    
    /* 获取验证码 登录 注册 忘记密码 重置密码 */
    func getAuthCode() {
        
        /// 0.验证手机号
        if !self.currentPhoneStr.isMobile {
            self.authError.accept(.failure(error: "手机号码不正确"))
            return
        }
        /// 1.记录当前获取验证码的手机号
        self.getAuthCodePhone = self.currentPhoneStr
        self.authCodeStatus.accept(.sendding)
        
        guard let type = self.authType else { return }
        guard let vCode = self.currentPhoneStr.encrypt() else { return }
        provider.rx
            .request(.getAuthCode(type: type, email_mobile: self.currentPhoneStr, vCode: vCode))
            .mapObject(AuthCodoResult.self)
            .subscribe(onSuccess: { [unowned self] (result) in
                if result.code == ResultCode.SUCCESS.rawValue { // 请求成功
                    self.vaildCode = result.data
                    self.countDown(60)
                    self.authCodeStatus.accept(.succes)
                    self.authError.accept(.success)
                    
                } else { // 请求失败
                    
                    if result.err_info != nil {
                        self.authError.accept(.failure(error: result.err_info!))
                    } else {
                        self.authError.accept(.failure(error: "系统错误"))
                    }
                    self.vaildCode = nil
                    self.getAuthCodePhone = ""
                    self.authCodeStatus.accept(.failure)
                }
            }) { (error) in
                self.getAuthCodePhone = ""
                self.authError.accept(.failure(error: "网络不给力"))
                self.authCodeStatus.accept(.failure)
            }.disposed(by: bag)
        
    }
    
    /* 倒计时 */
    func countDown(_ initinalCount: Int) {
        self.timerBag.accept(true)
        dispose = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
            .map{ initinalCount - $0 }
            .subscribe { [weak self] (ele) in
                guard let `self` = self else { return }
                if ele.element! == 0 {
                    /// 验证码输入超时 -> 显示重新获取
                    self.countDownStr.accept("重新获取")
                    self.authCodeStatus.accept(.timeout)
                    self.timerBag.accept(false)
                } else {
                    /// 验证码倒计时中
                    self.countDownStr.accept("重新获取(\(ele.element!))")
                }
        }
        timerBag.subscribe { [weak self] (running) in
            guard let `self` = self else { return }
            
            if !running.element! {
                self.dispose?.dispose()
                self.dispose = nil
            }
            }.disposed(by: bag)
    }
    
    /* 对验证码进行验证 */
    func verifyAuthCode() -> Bool {
        return self.authStr.md5.md5 == self.vaildCode
    }
    
    
    
}
