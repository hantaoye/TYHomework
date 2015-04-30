//
//  RyxLoginViewController.swift
//  FITogether
//
//  Created by closure on 11/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit

public class RyxLoginViewController : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    private var emailValid = false
    private var passwordValid = false
    
    private var gestureEmailTextField: UITapGestureRecognizer!
    private var gesturePasswordTextField: UITapGestureRecognizer!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.gestureEmailTextField = UITapGestureRecognizer(target: self.emailTextField, action: Selector("resignFirstResponder"))
        self.gesturePasswordTextField = UITapGestureRecognizer(target: self.passwordTextField, action: Selector("resignFirstResponder"))
        
        let imageView = UIImageView(image: UIImage(named: "register_background")!)
        imageView.contentMode  = .ScaleToFill
        self.tableView.backgroundView = imageView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardHide:"), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TalkingData.beginTrack(self.dynamicType)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        TalkingData.endTrack(self.dynamicType)
    }
    
    public func keyboardShow(notification: NSNotification) {
        self.tableView.addGestureRecognizer(self.gestureEmailTextField)
        self.tableView.addGestureRecognizer(self.gesturePasswordTextField)
    }
    
    public func keyboardHide(notification: NSNotification) {
        self.tableView.removeGestureRecognizer(self.gestureEmailTextField)
        self.tableView.removeGestureRecognizer(self.gesturePasswordTextField)
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        self.updateUI(textField)
    }
    
    private func verifyPassword(password: String?) -> Bool {
        if let p = password {
            return countElements(p) >= 1
        }
        return false
    }
    
    private func updateUI(textField: UITextField) {
        if textField == self.emailTextField {
            if countElements(self.emailTextField.text) > 0 {
                emailValid = RyxEmailVerify.verify(self.emailTextField.text)
            }
            if emailValid {
                self.emailTextField.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
            } else {
                self.loginLabel.enabled = false
                if countElements(self.emailTextField.text) == 0 {
                    RSProgressHUD.showErrorWithStatus("邮箱不能为空")
                } else {
                    RSProgressHUD.showErrorWithStatus("邮箱格式错误")
                }
                return
            }
        }
        
        passwordValid = verifyPassword(self.passwordTextField.text)
        if emailValid && passwordValid {
            self.loginLabel.enabled = true
            self.passwordTextField.resignFirstResponder()
        } else {
            self.loginLabel.enabled = false
        }
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            if countElements(self.emailTextField.text) > 0 {
                emailValid = RyxEmailVerify.verify(self.emailTextField.text)
            }
            if emailValid {
                textField.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
            } else {
                self.loginLabel.enabled = false
                if countElements(self.emailTextField.text) == 0 {
                    RSProgressHUD.showErrorWithStatus("邮箱不能为空")
                } else {
                    RSProgressHUD.showErrorWithStatus("邮箱格式错误")
                }
                return false
            }
        } else if textField == self.passwordTextField {
            passwordValid = verifyPassword(self.passwordTextField.text)
            if emailValid && passwordValid {
                self.loginLabel.enabled = true
                self.passwordTextField.resignFirstResponder()
                self.loginBtnPressed(nil)
            } else {
                self.loginLabel.enabled = false
                return false
            }
        }
        return true
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var str: NSMutableString = textField.text.mutableCopy() as NSMutableString
        str.replaceCharactersInRange(range, withString: string)
        if textField == passwordTextField {
            if verifyPassword(str) && emailValid {
                passwordValid = true
                loginLabel.enabled = true
            } else {
                passwordValid = false
                loginLabel.enabled = false
            }
        } else if textField == emailTextField {
            if RyxEmailVerify.verify(str) && passwordValid {
                emailValid = true
                loginLabel.enabled = true
            } else {
                emailValid = false
                loginLabel.enabled = false
            }
        }
        return true
    }
    
//    @IBAction func tapGestureAction(sender: UITapGestureRecognizer) {
//        if self._target == nil {
//            self._target?.resignFirstResponder()
//            self._target = nil
//        }
//    }
    
    @IBAction func loginBtnPressed(sender: UIButton?) {
        RyxLoginHelper.login(email: self.emailTextField.text, password: self.passwordTextField.text) { (account, error) -> Void in
            if account != nil {
                RyxBranchViewControllerLoader.loadMainEntry(true)
            }
        }
    }
    
    public override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return self.loginLabel.enabled
        }
        return false
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.loginLabel.enabled && indexPath.section == 1 && indexPath.row == 0 {
            // login 
            self.loginBtnPressed(nil)
        }
    }
    
    public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if let touch = event.allTouches()?.anyObject() as? UITouch {
            if touch.view != self.emailTextField {
                self.emailTextField.resignFirstResponder()
                if touch.view == self.passwordTextField {
                    self.passwordTextField.becomeFirstResponder()
                    self.updateUI(self.emailTextField)
                }
                
            } else if touch.view != self.passwordTextField {
                self.passwordTextField.resignFirstResponder()
                if touch.view == self.emailTextField {
                    self.emailTextField.becomeFirstResponder()
                    self.updateUI(self.passwordTextField)
                }
                
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
}
