//
//  RyxEditPhoto2ViewController.swift
//  FITogether
//
//  Created by taoYe on 14/12/26.
//  Copyright (c) 2014年 closure. All rights reserved.
//

import UIKit
import SQLite

public class RyxImage2ZoomHelper {
    public class func zoomRectForScale(view: UIView, scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = view.frame
        zoomRect.size.height = view.frame.size.height / scale
        zoomRect.size.width = view.frame.size.width / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
}


public class RyxEditCrop2PhotoViewController: PECropViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToEdieViewController(segue: UIStoryboardSegue) {
        println(segue.destinationViewController)
    }

}

@objc public protocol RyxEditPhoto2ViewControllerDelegate : NSObjectProtocol {
    optional func editPhotoViewController(editPhotoViewController: RyxEditPhoto2ViewController, didFinished image: UIImage!)
    optional func editPhotoViewControllerDidCancel(editPhotoViewController: RyxEditPhoto2ViewController)
}


public class RyxEditPhoto2ViewController: UIViewController, UIScrollViewDelegate {
    
    private var imageDao = RyxSharedStorage.sharedStorage().imageDao
    
    private var finalImage : UIImage? = nil
    private var token = ""
    
    public weak var delegate : RyxEditPhoto2ViewControllerDelegate? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: PECropView!
    
    @IBOutlet weak var filterView: UIScrollView!
    public var scaleValue : CGFloat = 1.0 {
        didSet {
            if self.scaleValue < 1.0 {
                self.scaleValue = 1.0
            }
        }
    }
    
    public var prepareEditImage : UIImage? = nil
    public var finishCroppedImage : UIImage? = nil
    private func setupScaleValue() {
        let target = self.imageView.bounds
        let targetSize = target.size
        let heigthGreaterThanWidth = targetSize.height > targetSize.width
        let screenBoundsSize = UIScreen.mainScreen().bounds.size
        if heigthGreaterThanWidth {
            self.scaleValue = screenBoundsSize.width / targetSize.width
        } else {
            self.scaleValue = screenBoundsSize.height / targetSize.height
        }
        if self.scaleValue > self.scrollView.maximumZoomScale {
            self.scaleValue = self.scrollView.maximumZoomScale
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.prepareEditImage
        self.setupScaleValue()
    }
    
    private func zoomRect() -> CGRect {
        return CGRectMake(0, 0, self.imageView.frame.width, self.imageView.frame.height)
    }
    
    @IBAction func nextStep(sender: AnyObject?) {
        
        var ch = chan<String>("")
        go {
            self.finalImage = UIImage.captureWithFirstImage(self.finishCroppedImage, secondImage: self.imageView.croppedImage, borderWidth: 10.0)
            if let fi = self.finalImage {
                self.finishCroppedImage = nil
                self.prepareEditImage = nil
                let token = "http://www.com.ryx.inc.finalImage"
                let cache = SDImageCache.sharedImageCache()
                cache.storeImage(fi, recalculateFromImage: true, imageData: nil, forKey: token, toDisk: true)
//                cache.storeImage(fi, recalculateFromImage: true, imageData: nil, forKey: token, toDisk: true, onlyDisk: true)
//                self.imageDao.add(RyxImage(token: token, image: self.finalImage))
                self.token = token
                self.finalImage = nil;
                ch <- token
            } else {
                ch <- ""
            }
        }
        RSProgressHUD.showWithStatus("Merging", maskType: RSProgressHUDMaskType.Gradient)
        go {
            if let result = <-ch {
                self.token = result
                run {
                    RSProgressHUD.dismiss()
                }
                if countElements(result) > 0 {
                    (dispatch_get_main_queue(), 2) ~>> {
                        self.performSegueWithIdentifier("segueForEditTag2", sender: sender)
                    }
                } else {
                    run {
                        RSProgressHUD.showErrorWithStatus("merge failed!")
                    }
                }
            }
        }
    }
    
    @IBAction func doubleTapGestureAction(sender: UITapGestureRecognizer) {
        if self.scrollView.zoomScale >= scaleValue {
            //            let location = sender.locationInView(self.imageView)
            //            self.scrollView.zoomToRect(RyxImageZoomHelper.zoomRectForScale(self.scrollView, scale: 1.0, withCenter: location), animated: true)
            self.scrollView.setZoomScale(1.0, animated: true)
        } else {
            //            self.scrollView.setZoomScale(scaleValue, animated: true)
            let location = sender.locationInView(self.imageView)
            self.scrollView.zoomToRect(RyxImageZoomHelper.zoomRectForScale(self.scrollView, scale: self.scaleValue, withCenter: location), animated: true)
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        if scale > 1.0 {
            self.scrollView.scrollEnabled = true
        } else {
            self.scrollView.scrollEnabled = false
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueForEditTag2" {
            let destination = segue.destinationViewController as RyxEditTagOCViewController
            destination.editImage = self.finalImage
//            destination.ima
            destination.token = self.token
        }
    }
}

public class RyxImageDaoHelper : RyxObject {
    private typealias T = RyxImage
    private typealias PK = RyxStringPK
    private var imageDao = RyxSharedStorage.sharedStorage().imageDao
    public func loadImageFromToken(token: String) -> UIImage? {
        if let image = imageDao.get(RyxStringPK(token: token)) {
            return image.image
        }
        return nil
    }
}
