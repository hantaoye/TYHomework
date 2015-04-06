//
//  RyxEmailRegisterViewController.swift
//  FITogether
//
//  Created by closure on 11/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit

public class RyxEmailRegisterViewController: RyxTextFieldKeyboardViewController {
    
    struct __Static {
        static let segueForProfile = "segueForProfile"
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    
    func isValid() -> (description: String?, valid: Bool) {
        func verifyEmptyField () -> (description: String?, valid: Bool) {
            var description: String? = nil
            var valid = true
            if 0 == countElements(self.nameTextField.text) {
                description  = RyxOptions.option().nameTextFieldEmptyError
                valid = false
            } else if 0 == countElements(self.emailTextField.text) {
                description  = RyxOptions.option().emailTextFieldEmptyError
                valid = false
            } else if 0 == countElements(self.passwordTextField.text) {
                description  = RyxOptions.option().passwordTextFieldEmptyError
                valid = false
            } else if 0 == countElements(self.verifyPasswordTextField.text) {
                description  = RyxOptions.option().verifyPasswordTextFieldEmptyError
                valid = false
            }
            
            return (description, valid)
        }
        
        var r = verifyEmptyField()
        if r.valid == false {
            return r
        }
        
        func verifiedEmailAddress() -> (description: String?, valid: Bool)  {
            var description: String? = nil
            var valid = RyxEmailVerify.verify(self.emailTextField.text)
            if !valid {
                description = RyxOptions.option().emailAddressFormatInvalid
            }
            return (description, valid)
        }
        
        r = verifiedEmailAddress()
        if r.valid == false {
            return r
        }
        
        func verifyPassword() -> (description: String?, valid: Bool) {
            var description: String? = nil
            var valid = countElements(self.passwordTextField.text) > 12
            if !valid {
                description = RyxOptions.option().passwordLengthShouldOver6Error
            } else if self.passwordTextField.text != self.verifyPasswordTextField.text {
                self.verifyPasswordTextField.becomeFirstResponder()
                description = RyxOptions.option().verifyPasswordNotMatchError
                valid = false
            } else {
                valid = true
            }
            return (description, valid)
        }
        
        r = verifyPassword()
        if r.valid == false {
            return r
        }
        return (nil, true)
    }
    
    @IBAction func registerBtnPressed(sender: AnyObject?) {
        let (err, valid) = isValid()
        if !valid {
            RSProgressHUD.showErrorWithStatus(err!)
            RyxDebugLogger.error(err!)
            return
        }
        RSProgressHUD.showWithStatus("注册中...", maskType: RSProgressHUDMaskType.Gradient)
        
        RyxAccountAccess.register(email: self.emailTextField.text, password: self.passwordTextField.text, name: self.nameTextField.text) { (account, error) -> Void in
            run {
                if error != nil {
                    RyxDebugLogger.error(error)
                    RSProgressHUD.showErrorWithStatus("账号或密码错误")
                    return
                } else {
                    RSProgressHUD.showSuccessWithStatus("注册成功")
                    RyxSharedStorage.sharedStorage().setupCacheStorageIfNecessary()
                    
                    (dispatch_get_main_queue(), 1.0) ~>> {
                        self.performSegueWithIdentifier(__Static.segueForProfile, sender: self)
                    }
                }
            }
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == __Static.segueForProfile {
            if let destination = segue.destinationViewController as? RyxFillProfileViewController {
                destination.title = "test"
            }
            return
        }
        super.prepareForSegue(segue, sender: sender)
    }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        super.setTextFields([self.nameTextField, self.emailTextField, self.passwordTextField, self.verifyPasswordTextField])
        super.doneAction = {
            self.registerBtnPressed(nil)
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TalkingData.beginTrack(self.dynamicType)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        TalkingData.endTrack(self.dynamicType)
    }
    
    deinit {
        println("\(self) dealloc")
    }
}
