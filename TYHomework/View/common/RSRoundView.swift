//
//  RyxRoundView.swift
//  FITogether
//
//  Created by closure on 11/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit

public extension UIImageView {
    public func round() {
//        self.image = self.image?.round(0)
        RyxRoundView.round(self, diameter: self.frame.height)
    }
}


public extension UIImage {
    public func round(inset: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2)
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        let rect = CGRectMake(inset, inset, self.size.width - inset * 2, self.size.height - inset * 2)
        CGContextAddEllipseInRect(context, rect)
        CGContextClip(context)
        self.drawInRect(rect)
        CGContextAddEllipseInRect(context, rect)
        CGContextStrokePath(context)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

public class RyxRoundView: RyxView {
    public class func round(view: UIView, diameter: CGFloat) {
        view.clipsToBounds = true
//        let saveCenter = view.center
        let newFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y, diameter, diameter)
        view.frame = newFrame
        view.layer.cornerRadius = diameter / 2.0
//        view.center = saveCenter
    }
    
    public override init() {
        super.init()
    }
    
    public func round() {
        RyxRoundView.round(self, diameter: self.frame.size.height)
    }
    
    public override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.round()
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }
    
    public override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
}

//public class RyxRoundImageView : UIImageView {
//    public required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.layer.masksToBounds = true
//        self.layer.cornerRadius = self.frame.height / 2
//    }
//}
