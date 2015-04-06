//
//  RyxFillPersonalMessageViewControllr.swift
//  FITogether
//
//  Created by closure on 12/2/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit

@objc public protocol RyxFillPersonalMessageViewControllrDelegate : NSObjectProtocol {
    optional func updatePersonalMessage(message: String?)
}

public class RyxFillPersonalMessageViewControllr : UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var personalMessageTextView: RyxPlaceholderTextView!
    
    public weak var delegate: RyxFillPersonalMessageViewControllrDelegate? = nil
    
    @IBAction func nextBarButtonPressed(sender: UIBarButtonItem) {
        if self.personalMessageTextView.text.complexLength() > 100 {
            RSProgressHUD.showErrorWithStatus("签名请小于100字符")
            return
        }
        if self.personalMessageTextView.text != nil && countElements(self.personalMessageTextView.text) > 0 {
            RSProgressHUD.showWithStatus("更新中...", maskType: RSProgressHUDMaskType.Gradient)
            RyxAccountAccess.updateInfo(nil, gender: -1, age: -1, location: nil, locationDescription: nil, introduction: self.personalMessageTextView.text, height: -1, weight: -1, avatar: nil, action: { (accoun, error) -> Void in
                if error == nil {
                    run {
                        RSProgressHUD.showSuccessWithStatus("完成")
                        RyxBranchViewControllerLoader.loadMainEntry(viewController: self)
                    }
                    return
                } else {
                    run {
                        RSProgressHUD.showErrorWithStatus("更新失败")
                    }
                    return
                }
            })
        } else {
            RyxBranchViewControllerLoader.loadMainEntry(viewController: self)
        }
    }
    
    public override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TalkingData.beginTrack(self.dynamicType)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        self.delegate?.updatePersonalMessage?(self.personalMessageTextView.text)
        super.viewWillDisappear(animated)
        TalkingData.endTrack(self.dynamicType)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.personalMessageTextView.becomeFirstResponder()
        let imageView = UIImageView(image: UIImage(named: "register_background")!)
        imageView.contentMode  = .ScaleToFill
        self.tableView.backgroundView = imageView
    }
    
    public func textViewDidChange(textView: UITextView){
        if countElements(textView.text) >= 1 {
            let lastChar = textView.text.substringFromIndex(advance(textView.text.endIndex, -1))
            if(lastChar == "\n"){
                textView.text = textView.text.substringToIndex(advance(textView.text.endIndex, -1))
                
                textView.resignFirstResponder()
                self.navigationController?.popViewControllerAnimated(true)
            }
            
        }
    }
}
