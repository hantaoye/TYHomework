//
//  RyxForgetPasswordViewController.swift
//  FITogether
//
//  Created by closure on 1/13/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

import UIKit

public class RyxForgetPasswordViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var emailTextField: UITextField!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TalkingData.beginTrack(self.dynamicType)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        TalkingData.endTrack(self.dynamicType)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func updateUI() {
        if countElements(self.emailTextField.text) == 0 {
            RSProgressHUD.showErrorWithStatus("邮箱不能为空")
            return
        } else if RyxEmailVerify.verify(self.emailTextField.text) {
            RSProgressHUD.showErrorWithStatus("邮箱格式错误")
            return
        }
        self.emailTextField.resignFirstResponder()
        self.doneButton.enabled = true
    }
    
    
    @IBAction func doneButtonPressed(sender: AnyObject?) {
        RSProgressHUD.showWithStatus("邮件发送中...", maskType: .Gradient)
        RyxAccountAccess.findPasswordByEmail(self.emailTextField.text, action: { (error) -> Void in
            if error != nil {
                run {
                    RSProgressHUD.showErrorWithStatus("发送失败")
                }
            } else {
                run {
                    RSProgressHUD.showSuccessWithStatus("发送成功, 请注意查收")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        })
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.updateUI()
            if self.doneButton.enabled {
                
            }
            return true
        }
        return false
    }
    
}
