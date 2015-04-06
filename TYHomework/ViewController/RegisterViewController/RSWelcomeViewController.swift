
//
//  RyxWelcomeViewController.swift
//  FITogether
//
//  Created by closure on 12/1/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit

public class RyxWelcomeViewController : UIViewController, RyxWechatResponseDelegate {
    
    @IBOutlet weak var weiboLoginButton: UIButton!
    @IBOutlet weak var wechatLoginButton: UIButton!
    
    @IBAction func weiboLoginButtonPressed(sender: UIButton?) {
        RyxSharedStorage.sharedStorage().middleware.weiboDelegate.authorize { (weiboResponse) -> Void in
            if weiboResponse != nil {
                RyxLoginHelper.login(weiboToken: weiboResponse!.accessToken, action: { (account, error) -> Void in
                    if account != nil {
                        RyxBranchViewControllerLoader.loadMainEntry(true)
                    }
                })
            }
            return
        }
    }
    
    @IBAction func wechatLoginButtonPressed(sender: UIButton) {
        RyxSharedStorage.sharedStorage().middleware.wechatDelegate.delegate = self
        RyxSharedStorage.sharedStorage().middleware.wechatDelegate.authroize(self)
    }
    
    public func authResponse(response: SendAuthResp!) {
        if response.errCode == 0 {
            RyxLoginHelper.login(wechatCode: response.code, action: { (account, error) -> Void in
                if account != nil {
                    RyxBranchViewControllerLoader.loadMainEntry(true)
                }
            })
        } else {
//            RSProgressHUD.showErrorWithStatus("")
        }
    }
    
    private func checkWeiboSDK() -> Bool {
        if let weiboSDKDelegateClass: AnyClass = NSClassFromString("FITogether.RyxWeiboSDKDelegate") {
            return true
        }
        return false
    }
    
    private func chcekWechateSDK() -> Bool {
        if let wechatSDKDelegateClass: AnyClass = NSClassFromString("FITogether.RyxWechatSDKDelegate") {
            return true
        }
        return false
    }
    
    private func check3rdSDK() {
        if !checkWeiboSDK() {
            self.weiboLoginButton.enabled = false
            self.weiboLoginButton.hidden = true
        }
        
        if !checkWeiboSDK() {
            self.wechatLoginButton.enabled = false
            self.wechatLoginButton.hidden = true
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        super.viewDidAppear(animated)
        RyxNotificationCenter.defaultCenter().stopMonitor()
        TalkingData.beginTrack(self.dynamicType)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
        super.viewWillDisappear(animated)
        TalkingData.endTrack(self.dynamicType)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.check3rdSDK()
    }
}
