//
//  RyxTrackPostTableViewController.swift
//  FITogether
//
//  Created by closure on 12/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit
import CoreLocation

public extension UINavigationController {
    public func rootViewController() -> UIViewController? {
        return self.childViewControllers[0] as? UIViewController
    }
}

public class RyxTrackPostTableViewController: UITableViewController, RyxImagePickerSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate, RyxEditPhotoViewControllerDelegate, RyxImagePickerControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageButton: UIButton!
  //  @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var shouldPerformEditPhotoViewController = false
    var image1: UIImage? = nil
//        {
//        didSet {
//            self.imageButton.setBackgroundImage(self.image1, forState: UIControlState.Normal)
//        }
//    }
    var image2: UIImage? = nil
    
    var tags: [RyxPhotoTag]? = nil
    var photoDescription = ""
    var locationDescription = ""
    
    private var _location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    public var location: CLLocationCoordinate2D {
        get {
            var v : CLLocationCoordinate2D
            objc_sync_enter(self)
            v = _location
            objc_sync_exit(self)
            return v
        }
        
        set {
            objc_sync_enter(self)
            _location = newValue
            objc_sync_exit(self)
        }
    }
    private var locationManager: RyxLocationManager = RyxLocationManager.defaultManager()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.currentLocation { (l, error) -> Void in
            if l != nil {
                self.location = l!.coordinate
                let geoCoder = CLGeocoder()
                geoCoder.reverseGeocodeLocation(l, completionHandler: { (results, error) -> Void in
                    if error != nil {
                        RyxDebugLogger.error(error)
                    } else if let marker = results?.first as? CLPlacemark {
                        dispatch_get_main_queue() ~>> {
                            self.locationLabel.text = "\(marker.subLocality) , \(marker.locality)"
                        }
                    }
                })
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    // MARK: - Table view data source
//
//    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }
    
    private func jumpToEditCropPhotoViewController() {
        self.performSegueWithIdentifier("segueForEditCropPhoto", sender: self)
    }
    
    private func jumpToEditPhotoViewController() {
        self.performSegueWithIdentifier("segueForEditPhoto", sender: self)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldPerformEditPhotoViewController {
            self.shouldPerformEditPhotoViewController = false
            self.jumpToEditPhotoViewController()
        }
    }
    
    // MARK: - RyxImagePickerSheetDelegate
    
    
    public func imagePickerSheet(imagePickerSheet: RyxImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String {
        var x : [String]!
        if imagePickerSheet.numberOfSelectedPhotos > 1 {
            x = ["Choose \(imagePickerSheet.numberOfSelectedPhotos) photos", "Photo Library", "Cancel"]
        } else if imagePickerSheet.numberOfSelectedPhotos == 1 {
            x = ["Choose \(imagePickerSheet.numberOfSelectedPhotos) photo", "Photo Library", "Cancel"]
        } else {
            x = ["Choose photo", "Photo Library", "Cancel"]
        }
        return  x[buttonIndex]
    }
    
    func presentRyxPickerController() {
        let storyboard = UIStoryboard(name: "RyxImagePickerController", bundle: nil)
        let entry = storyboard.instantiateInitialViewController() as RyxImagePickerController
        entry.delegate = self
        entry.imagePickerDelegate = self
        self.presentViewController(entry, animated: true, completion: nil)
    }
    
    public func imagePickerSheet(imagePickerSheet: RyxImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != imagePickerSheet.cancelButtonIndex {
            if buttonIndex == 0 {
                // choose
                if imagePickerSheet.numberOfSelectedPhotos > 0 {
                    imagePickerSheet.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.image1 = images.first
                        if imagePickerSheet.numberOfSelectedPhotos > 1 {
                            self.image2 = images[1]
                        }
                        self.jumpToEditPhotoViewController()
                    })
                }
            } else if buttonIndex == 1 {
                // photo library
                self.presentRyxPickerController()
            }
        }
    }
    
    
    public func presentImagePickerSheet(sender: UIButton) {
        var sheet = RyxImagePickerSheet()
        sheet.maxSelect = 2
        sheet.numberOfButtons = 3
        sheet.delegate = self
        sheet.showInView(self.view)
    }
    
    // MARK: - UIImagePickerControllerDelegate

    @IBAction func pickImageButtonPressed(sender: UIButton) {
        self.presentImagePickerSheet(sender)
    }
    
    // MARK: - PECropViewControllerDelegate 
    
    public func cropViewController(controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.image1 = croppedImage
    }
    
    public func cropViewControllerDidCancel(controller: PECropViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerController(picker: RyxImagePickerController, didFinishPickingMediaWithInfo info: [AnyObject]) {
        for dict in info as [[String: NSObject]] {
            if let image = dict[UIImagePickerControllerOriginalImage] as UIImage! {
                self.image1 = image
            } else if let image = dict[UIImagePickerControllerEditedImage] as UIImage! {
                self.image1 = image
            }
            self.shouldPerformEditPhotoViewController = true
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
//    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        if let image = info[UIImagePickerControllerEditedImage] as UIImage! {
//            self.imageView.image = image
//        } else if let image = info[UIImagePickerControllerOriginalImage] as UIImage! {
//            self.imageView.image = image
//        }
//        self.shouldPerformEditPhotoViewController = true
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }

    public override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    private func handleUnwindFromEditTagViewController(viewController: RyxEditTagOCViewController!) {
        self.imageButton .setBackgroundImage(viewController.editImage, forState: UIControlState.Normal)
        if let x = viewController.tags.mutableCopy() as? [RyxPhotoTag] {
            self.tags = x
        }
    }
    
    @IBAction func unwindToPostTableViewController(segue: UIStoryboardSegue) {
        println(segue.sourceViewController)
        println(segue.destinationViewController)
        if let sourceVC = segue.sourceViewController as? RyxImagePickerPlaceHolderViewController {
            println(sourceVC.firstImageView)
            println(sourceVC.secondImageView)
            self.image1 = sourceVC.firstImageView.image
            self.image2 = sourceVC.secondImageView.image
            self.shouldPerformEditPhotoViewController = true
        } else if let sourceVC = segue.sourceViewController as? RyxEditTagOCViewController {
            return self.handleUnwindFromEditTagViewController(sourceVC)
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueForEditCropPhoto" {
            if let navigation = segue.destinationViewController as? UINavigationController {
                if let destination = navigation.rootViewController() as? RyxEditCropPhotoViewController {
                    destination.image = self.image1
                    destination.toolbarHidden = false
                    destination.delegate = self
                }
            }
        } else if segue.identifier == "segueForEditPhoto" {
            if let navigation = segue.destinationViewController as? UINavigationController {
                if let destination = navigation.rootViewController() as? RyxEditPhotoViewController {
                    destination.prepareEditImage = self.image1
                    destination.reserveEditImage = self.image2
                    destination.delegate = self
                }
            }
        }
    }
    
    @IBAction public func shareAction(sender: AnyObject?) {
        let photo = RyxPhoto(ID: 0, filterID: 0, url:"", latitude: _location.latitude, longtitude: _location.longitude, locationDescription: self.locationDescription, author: RyxAccount.currentAccount()!.ID, photoDescription: self.photoDescription, tags: self.tags, atUsers: nil)
        photo.image = self.image1
        
        RyxPhotoAccess.create(photo, action: { (photo, error) -> Void in
            
        })
    }
}
