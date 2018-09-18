//
//  LoginViewModel.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/6/28.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

/// 登录方式
public enum LoginType {
    case account    // 账号密码登录
    case authCode   // 验证码登录
}


public enum LoginError {
    case none
    case success
    case logining
    case failure(error: String)
}

public class LoginViewModel: AuthCodeViewModel {
    /// 登录点击事件
    var _loginTap: Observable<Void>
    /// 登录方式
    var _loginType: BehaviorRelay<LoginType>!
    /// 登录按钮的状态
    var _loginState = BehaviorRelay.init(value: false)
    /// 登录的错误信息
    var loginErrInfo = BehaviorRelay.init(value: LoginError.none)
    
    init(authInput: Observable<String?>,
         phoneInput: Observable<String?>,
         getAuthTap: Observable<Void>,
         loginSingal: Observable<Void>,
         loginTypeSingal: BehaviorRelay<LoginType>,
         loginEnable: Binder<Bool>,
         authCountDown: Binder<String?>,
         authButtonStatus: Binder<AuthCodeButtonType>,
         authApi: AuthCodeType)
    {
        _loginTap = loginSingal
        _loginType = loginTypeSingal
        super.init(input: (authInput, phoneInput, getAuthTap, authCountDown, authButtonStatus), authApi: authApi)
        _loginState.asDriver().drive(loginEnable).disposed(by: bag)
        observerLogin()
    }
}

extension LoginViewModel {
    
    func observerLogin() {
        _loginTap.subscribe { [unowned self] (event) in
            self._loginState.accept(false)
            self._loginType?.value == .account ? self.accountLoginAction() : self.authCodeLogin()
        }.disposed(by: bag)
        
        authAcountIsVaild.subscribe { [unowned self] (isOk) in
            self._loginState.accept(isOk.element! ? true : false)
        }.disposed(by: bag)
    }
    
}

//// MARK: - 处理登录的网络模块的逻辑
extension LoginViewModel {
    /// 账号登录
    func accountLoginAction() {
        self.loginErrInfo.accept(.logining)
        provider.rx.request(.login(email_mobile: self.currentPhoneStr, psw: self.authStr, vCode: nil)).mapObject(NetBaseModel<LoginUserInfo>.self).subscribe(onSuccess: { [unowned self]
            (result) in
            guard let code = result.code else { return }
            if code != ResultCode.SUCCESS.rawValue { // 登录失败
                guard let err = result.err_info else {
                    self.loginErrInfo.accept(.failure(error: "系统错误导致登录失败"))
                    return
                }
                self.loginErrInfo.accept(.failure(error: err))
            } else { // 登录成功
                self.loginErrInfo.accept(.success)
                guard let user = result.data else {
                    self._loginState.accept(true)
                    return
                }
                LoginUserInfo._userinfo = user
            }
            self._loginState.accept(true)
            
        }) { (error) in
            self.loginErrInfo.accept(.failure(error: "网络不给力"))
            self._loginState.accept(true)
        }.disposed(by: bag)
    }
    /// 验证码登录
    func authCodeLogin() {
        self.loginErrInfo.accept(.logining)
        // 1.判断验证码是否正确
        if !self.verifyAuthCode() {
            self.loginErrInfo.accept(.failure(error: "验证码错误"))
            self._loginState.accept(true)
            return
        }
        // 2.正式发起请求
        provider.rx.request(.loginByAuthcode(mobile: self.currentPhoneStr, code: self.authStr)).mapObject(NetBaseModel<LoginUserInfo>.self).subscribe(onSuccess: { [unowned self] (result) in
            guard let code = result.code else { return }
            if code != ResultCode.SUCCESS.rawValue { // 登录失败
                guard let err = result.err_info else {
                    self.loginErrInfo.accept(.failure(error: "系统错误导致登录失败"))
                    return
                }
                self.loginErrInfo.accept(.failure(error: err))
                
            } else { // 登录成功
                self.loginErrInfo.accept(.success)
                guard let user = result.data else {
                    self._loginState.accept(true)
                    return
                }
                LoginUserInfo._userinfo = user
            }
            self._loginState.accept(true)
        }) { (err) in
            self.loginErrInfo.accept(.failure(error: "网络不给力"))
            self._loginState.accept(true)
        }.disposed(by: bag)
    }
}
