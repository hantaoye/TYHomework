//
//  RyxTextFieldKeyboardViewController.swift
//  FITogether
//
//  Created by closure on 11/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit

public class RyxTextFieldKeyboardViewController : UIViewController, UITextFieldDelegate {
    private weak var _target: UITextField? = nil
    
    private var floatingKeyboard = false
    
    private var textFields:[UITextField]?
    
    public typealias RyxTextFieldKeyboardDoneAction = () -> Void
    
    public var doneAction: RyxTextFieldKeyboardDoneAction?
    
    public var shouldFloatingUI = true
    
    private lazy var motion: UIMotionEffect = {
        let motionXMinValue:CGFloat = -20.0
        let motionYMinValue:CGFloat = -20.0
        
        let motionXMaxValue:CGFloat = 20.0
        let motionYMaxValue:CGFloat = 20.0
        
        let xAxis = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        xAxis.minimumRelativeValue = motionXMinValue
        xAxis.maximumRelativeValue = motionXMaxValue
        
        let yAxis = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        yAxis.minimumRelativeValue = motionYMinValue
        yAxis.maximumRelativeValue = motionYMaxValue
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xAxis, yAxis]
        return group
    }()
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        _target = textField
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        _target = nil
    }
    
    public func setTextFields(textFields: [UITextField]) {
        deapplyMotion()
        self.textFields = textFields
        for textField in self.textFields! {
            textField.delegate = self
        }
        applyMotion()
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let index = find(self.textFields!, textField) {
            if index + 1 == self.textFields!.count {
                tipGestureActive(nil)
                if self.doneAction != nil {
                    self.doneAction!()
                }
            } else {
                self.textFields![index + 1].becomeFirstResponder()
            }
        }
        return true
    }
    
    @IBAction func tipGestureActive(sender: UITapGestureRecognizer?) {
        _target?.resignFirstResponder()
        _target = nil
    }
    
    public var fbixt: CGFloat = 2.2 {
        didSet {
            if fbixt < 1.0 {
                fbixt = 2.2
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if self.floatingKeyboard {
            return
        }
        
        if !self.shouldFloatingUI {
            return
        }
        
        self.floatingKeyboard = true
        let info = notification.userInfo
        let kbSize = info![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        var newFrame = self.view.frame
        newFrame.origin.y -= (kbSize.height / fbixt)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = newFrame
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if !self.floatingKeyboard {
            return
        }
        if !self.shouldFloatingUI {
            return
        }
        self.floatingKeyboard = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = self.view.bounds
        })
    }
    
    func bindKeyboardNotification() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unbindKeyboardNotification() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }
    
    func applyMotion() {
        for view in self.view.subviews {
            view.addMotionEffect(self.motion)
        }
    }
    
    func deapplyMotion() {
        for view in self.view.subviews {
            view.removeMotionEffect(self.motion)
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        bindKeyboardNotification()
        TalkingData.beginTrack(self.dynamicType)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        deapplyMotion()
        unbindKeyboardNotification()
        TalkingData.endTrack(self.dynamicType)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: Selector("tipGestureActive:"))
        self.view.addGestureRecognizer(gesture)
    }
}

