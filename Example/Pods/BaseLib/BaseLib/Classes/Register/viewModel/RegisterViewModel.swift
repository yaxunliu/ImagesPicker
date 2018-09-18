//
//  RegisterViewModel.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/7/3.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya


/// 注册/找回密码的错误信息
public enum RegistStatus {
    case none
    case error(err: String)
    case noError
    case resetOk
    case registting // 正在注册中
    case resetting // 正在重置
}


class RegisterViewModel: AuthCodeViewModel {
    /// 下一步或者完成点击信号
    fileprivate var _nextTap: Observable<Void>!
    /// 记录当前用户是否已读风险协议 (可选)
    fileprivate var _hasReadRiskProtocol: BehaviorRelay<Bool> = BehaviorRelay.init(value: true)
    /// 注册按钮是否可以点击
    fileprivate var nextEnabel = BehaviorRelay.init(value: false)
    /// 用户密码 和 手机号输入框
    fileprivate var firstPwdSingal: BehaviorRelay<String?> = BehaviorRelay.init(value: "")
    /// 确认输入密码 和 验证码输入框
    fileprivate var secondPwdSingal: BehaviorRelay<String?> = BehaviorRelay.init(value: "")
    /// 当前状态
    var currentStatus = BehaviorRelay<RegistStatus>.init(value: .none)
    
    
    
    /// 与注册站好或者找回密码绑定
    ///
    /// - Parameters:
    ///   - phoneNumSingal: 手机号输入信号
    ///   - authcodeSingal: 验证码输入信号
    ///   - getAuthSingal: 获取验证码点击信号
    ///   - nextTapSingal: 下一步点击信号
    ///   - nextStepEnableSingal: 下一步按钮或者完成按钮是否可以点击信号
    ///   - authCountDownSingal: 获取验证码倒计时
    ///   - authButtonStatus: 验证码按钮状态
    ///   - riskProtocolSingal: 风险提示信号
    ///   - authApi: 获取验证码的api
    init(phoneNumSingal: Observable<String?>,
         authcodeSingal: Observable<String?>,
         getAuthSingal: Observable<Void>,
         nextTapSingal: Observable<Void>,
         nextStepEnableSingal: Binder<Bool>,
         authCountDownSingal: Binder<String?>,
         authButtonStatus: Binder<AuthCodeButtonType>,
         riskProtocolSingal: Observable<Bool>,
         authApi: AuthCodeType)
    {
        
        super.init(input:(authcodeSingal, phoneNumSingal, getAuthSingal, authCountDownSingal, authButtonStatus), authApi: authApi)

        // 1. 点击下一步或者完成信号
        _nextTap = nextTapSingal
        // 2.下一步或者完成是否可以点击
        nextEnabel.asDriver().drive(nextStepEnableSingal).disposed(by: self.bag)
        // 3.风险协议
        riskProtocolSingal.bind(to: _hasReadRiskProtocol).disposed(by: self.bag)
        
        // 4.记录下密码输入信号 (在下一步按钮点击之前的数据 都不是正确的数据)
        phoneNumSingal.bind(to: firstPwdSingal).disposed(by: self.bag)
        authcodeSingal.bind(to: secondPwdSingal).disposed(by: self.bag)
        
        // 5.开始监听
        observer()
        
        
        
    }
    
    
    func observer() {
        
        // 1.监听下一步按钮点击 (是否可以进入设置密码界面, 完成密码修改和注册)
        _nextTap.subscribe { [weak self] event in
            let authPass = self?.authCodePass.value ?? false
            if !authPass { // 进入设置密码
                self?.goSetupPwd()
                return
            }
            if self?.firstPwdSingal.value != self?.secondPwdSingal.value || self?.firstPwdSingal.value == nil || self?.secondPwdSingal.value == nil {
                self?.currentStatus.accept(.error(err: "两次设置的密码不一样"))
                return
            }
            
            
            // 确认密码
            if self?.authType == .regist { // 注册
                self?.registAccount()
            } else { // 找回密码
                self?.findBackPwd()
            }
        }.disposed(by: bag)
        
        // 2.判断下一步是否可以点击
        secondPwdSingal.subscribe { [weak self] authCode in
            guard let `self` = self else { return }
            guard let code = authCode.element ?? nil else {
                self.nextEnabel.accept(false)
                return
            }
            guard let phone = self.firstPwdSingal.value else {
                self.nextEnabel.accept(false)
                return
            }
            self.nextEnabel.accept(code.count > 0 && phone.count > 0 && self._hasReadRiskProtocol.value)
        }.disposed(by: bag)
        firstPwdSingal.subscribe { [weak self] authCode in
            guard let `self` = self else { return }
            guard let code = authCode.element ?? nil else {
                self.nextEnabel.accept(false)
                return
            }
            guard let phone = self.secondPwdSingal.value else {
                self.nextEnabel.accept(false)
                return
            }
            self.nextEnabel.accept(code.count > 0 && phone.count > 0 && self._hasReadRiskProtocol.value)
        }.disposed(by: bag)
        
        self._hasReadRiskProtocol.map({ (isSelect) -> Bool in
            if isSelect {
                return self.firstPwdSingal.value != nil && self.secondPwdSingal.value != nil && self.firstPwdSingal.value!.count > 0 && self.secondPwdSingal.value!.count > 0
            } else {
                return false
            }
        }).bind(to: self.nextEnabel).disposed(by: bag)
        
        
    }

}

extension RegisterViewModel {

    /* 点击下一步 */
    func goSetupPwd() {
        // 1.验证手机号是不是之前获取验证码的手机号
        if self.currentPhoneStr != self.getAuthCodePhone {
            let error = self.getAuthCodePhone.count == 0 ? "该手机号还未获取验证码" : "手机号和验证码不匹配"
            self.currentStatus.accept(.error(err: error))
            return
        }
        // 2.验证验证码是否正确
        if !self.verifyAuthCode() { // 验证没有通过
            self.currentStatus.accept(.error(err: "验证码输入错误"))
            return
        }
        // 3.验证码通过验证 -> 进入设置密码界面
        authCodePass.accept(true)
    }
    
    
    
    /* 注册账号 */
    func registAccount() {
        self.currentStatus.accept(.registting)
        provider.rx
            .request(.regist(email_mobile: self.getAuthCodePhone, code: self.authStr, psw: self.secondPwdSingal.value! , utype: nil))
            .mapObject(AuthCodoResult.self)
            .subscribe(onSuccess: { (result) in
                if result.code == ResultCode.SUCCESS.rawValue { // 请求成功
                    self.currentStatus.accept(.noError)
                } else { // 请求失败
                    if result.err_info != nil {
                        self.currentStatus.accept(.error(err: result.err_info!))
                    } else {
                        self.currentStatus.accept(.error(err: "系统故障"))
                    }
                }
            }) { (error) in
                self.currentStatus.accept(.error(err: "网络不给力"))
        }.disposed(by: bag)
    }
    
    /* 找回密码 */
    func findBackPwd() {

        self.currentStatus.accept(.resetting)
        provider.rx
            .request(.resetPassword(email_mobile: self.getAuthCodePhone, psw: self.secondPwdSingal.value!, code: self.authStr))
            .mapObject(AuthCodoResult.self)
            .subscribe(onSuccess: { (result) in
                if result.code == ResultCode.SUCCESS.rawValue { // 请求成功
                    self.currentStatus.accept(.resetOk)
                } else { // 请求失败
                    if result.err_info == nil {
                        self.currentStatus.accept(.error(err: "系统故障"))
                    } else {
                        self.currentStatus.accept(.error(err: result.err_info!))
                    }
                }
            }, onError: { (error) in
                self.currentStatus.accept(.error(err: "网络不给力"))
            }).disposed(by: bag)
    }
    
}
